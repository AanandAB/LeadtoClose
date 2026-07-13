
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class PaymentTrackerScreen extends ConsumerStatefulWidget {
  final String leadId;
  const PaymentTrackerScreen({super.key, required this.leadId});

  @override
  ConsumerState<PaymentTrackerScreen> createState() => _PaymentTrackerScreenState();
}

class _PaymentTrackerScreenState extends ConsumerState<PaymentTrackerScreen> {
  int _daysOverdue = 15;
  bool _hasUdyam = false;
  final double _invoiceAmount = 100000;
  final double _limitationYears = 3;

  @override
  Widget build(BuildContext context) {
    // Simulated — in production this would come from actual invoice data
    final steps = _getEscalationSteps();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Payment Recovery', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Days overdue slider
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight.withOpacity(0.3))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Invoice Age Simulator', style: AppTypography.heading2(context).copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text('Slide to see what actions are available at each stage', style: AppTypography.bodySmall(context)),
              const SizedBox(height: 16),
              Row(children: [
                Text('0 days', style: AppTypography.caption(context)),
                Expanded(
                  child: Slider(
                    value: _daysOverdue.toDouble(), min: 0, max: 120,
                    divisions: 120, activeColor: _daysOverdue > 90 ? AppColors.danger : _daysOverdue > 30 ? AppColors.warning : AppColors.info,
                    onChanged: (v) => setState(() => _daysOverdue = v.toInt()),
                  ),
                ),
                Text('120 days', style: AppTypography.caption(context)),
              ]),
              Center(
                child: Text('${_daysOverdue} days overdue',
                    style: AppTypography.heading2(context).copyWith(
                      color: _daysOverdue > 90 ? AppColors.danger : _daysOverdue > 30 ? AppColors.warning : AppColors.textPrimary,
                    )),
              ),
              const SizedBox(height: 8),
              // Limitation period tracker
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.timer, color: AppColors.danger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Limitation Period Tracker', style: AppTypography.label(context).copyWith(color: AppColors.danger)),
                    Text('${(3 * 365 - _daysOverdue)} days remaining before 3-year limitation expires (Limitation Act, 1963)',
                        style: AppTypography.bodySmall(context)),
                  ])),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Udyam toggle
          Row(children: [
            Text('Udyam/MSME registered?', style: AppTypography.body(context)),
            const Spacer(),
            Switch(value: _hasUdyam, onChanged: (v) => setState(() => _hasUdyam = v), activeColor: AppColors.success),
          ]),

          const SizedBox(height: 20),
          Text('Recovery Escalation Ladder', style: AppTypography.heading2(context)),
          const SizedBox(height: 4),
          Text('Cheapest/fastest option first — walk up the ladder as time passes',
              style: AppTypography.bodySmall(context)),
          const SizedBox(height: 16),

          // Escalation steps
          ...steps.map((step) {
            final isAvailable = _daysOverdue >= step['minDays']!;
            final isMsme = step['key'] == 'msme' && !_hasUdyam;

            return Opacity(
              opacity: isAvailable && !isMsme ? 1.0 : 0.35,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAvailable && !isMsme ? AppColors.bgCard : AppColors.bgCard.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable && !isMsme
                        ? step['color'] as Color
                        : AppColors.borderLight.withOpacity(0.2),
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(step['icon'] as IconData, size: 20, color: isAvailable ? step['color'] as Color : AppColors.textMuted),
                    const SizedBox(width: 10),
                    Expanded(child: Text(step['title'] as String, style: AppTypography.label(context).copyWith(
                      color: isAvailable ? AppColors.textPrimary : AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isAvailable ? (step['color'] as Color) : AppColors.textMuted).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(isAvailable ? 'AVAILABLE' : 'Day ${step['minDays']}+',
                          style: AppTypography.caption(context).copyWith(
                            color: isAvailable ? step['color'] as Color : AppColors.textMuted, fontSize: 9,
                          )),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(step['desc'] as String, style: AppTypography.body(context).copyWith(fontSize: 12)),
                  if (isMsme)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('Requires Udyam registration. Toggle above to enable.',
                          style: AppTypography.caption(context).copyWith(color: AppColors.warning)),
                    ),
                  const SizedBox(height: 8),
                  if (isAvailable && !isMsme)
                    Text(step['action'] as String, style: AppTypography.bodySmall(context).copyWith(
                      color: (step['color'] as Color), fontWeight: FontWeight.w600,
                    )),
                ]),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Summary reference pack
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.folder_zip, color: AppColors.primaryLight, size: 20),
                const SizedBox(width: 10),
                Text('Civil Suit Reference Pack', style: AppTypography.label(context).copyWith(color: AppColors.primaryLight)),
              ]),
              const SizedBox(height: 8),
              Text('If escalation fails, export all documents as one pack for a lawyer:\n'
                  '  - Signed contract\n  - All invoices\n  - Payment history\n  - Communication logs\n'
                  '  - Limitation period timestamp',
                  style: AppTypography.body(context).copyWith(fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  List<Map<String, dynamic>> _getEscalationSteps() {
    return [
      {
        'key': 'friendly', 'minDays': 1, 'title': 'Step 1: Friendly Reminder',
        'icon': Icons.email_outlined, 'color': AppColors.info,
        'desc': 'Auto-drafted email/WhatsApp message: "Hi [Client], just a gentle reminder that invoice [INV-XXX] for [amount] is due. Please let us know if you need any clarification."',
        'action': 'Copy message to clipboard',
      },
      {
        'key': 'firm', 'minDays': 15, 'title': 'Step 2: Firm Reminder + Late Fee Notice',
        'icon': Icons.warning_amber, 'color': AppColors.warning,
        'desc': 'References the contract late-fee clause. Recalculates amount with interest at the contract rate. Includes a clear statement that continued non-payment will trigger formal escalation.',
        'action': 'Generate late fee notice with recalculated amount',
      },
      {
        'key': 'legal_notice', 'minDays': 30, 'title': 'Step 3: Legal Notice Draft',
        'icon': Icons.gavel, 'color': AppColors.warning,
        'desc': 'Structured legal notice summary (parties, amount, invoice refs, contract refs) ready to hand to a lawyer. Saves the cost of a lawyer drafting from scratch.',
        'action': 'Generate legal notice summary',
      },
      {
        'key': 'msme', 'minDays': 45, 'title': 'Step 4: MSME Samadhaan Complaint',
        'icon': Icons.business_center, 'color': AppColors.success,
        'desc': 'Pre-filled MSME Samadhaan complaint summary. Available because the freelancer has Udyam registration. MSME Act mandates 45-day payment — this is a government-backed free dispute mechanism.',
        'action': 'Generate MSME Samadhaan pre-filled complaint',
      },
      {
        'key': 'consumer', 'minDays': 60, 'title': 'Step 5: District Consumer Commission',
        'icon': Icons.account_balance, 'color': AppColors.danger,
        'desc': 'If the client is a business and amount is under \u{20B9}50 lakh, the District Consumer Commission is a faster, cheaper alternative to civil court.',
        'action': 'Generate Consumer Commission complaint summary',
      },
      {
        'key': 'civil', 'minDays': 90, 'title': 'Step 6: Civil Recovery Suit',
        'icon': Icons.balance, 'color': AppColors.danger,
        'desc': 'Compiles all invoices, signed contract, communication logs, and payment history into one exportable pack for a lawyer to file under the Civil Procedure Code.',
        'action': 'Export complete recovery pack',
      },
    ];
  }
}
