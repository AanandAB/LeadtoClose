
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class TaxCalendarScreen extends ConsumerStatefulWidget {
  const TaxCalendarScreen({super.key});

  @override
  ConsumerState<TaxCalendarScreen> createState() => _TaxCalendarScreenState();
}

class _TaxCalendarScreenState extends ConsumerState<TaxCalendarScreen> {
  double _grossReceipts = 3500000;
  double _expenses = 500000;
  bool _isGstRegistered = true;
  bool _isExporting = true;

  @override
  Widget build(BuildContext context) {
    final netIncome = _grossReceipts - _expenses;
    final isUnder44ada = _grossReceipts <= 7500000;
    final isUnder50L = _grossReceipts <= 5000000;
    final presumptiveTax = netIncome * 0.50; // 50% deemed profit, taxed at slab
    final advanceTaxEstimate = _grossReceipts * 0.50 * 0.30; // rough 30% estimate

    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        title: Text('Tax & Compliance Calendar', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Tax Method Recommender
          _sectionChip('Tax Method Recommender'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.success.withOpacity(0.15), AppColors.success.withOpacity(0.05)]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 22),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  isUnder44ada ? 'Section 44ADA (Presumptive) Recommended' : 'Regular Books (ITR-3) Required',
                  style: AppTypography.heading2(context).copyWith(color: AppColors.success),
                )),
              ]),
              const SizedBox(height: 12),
              _infoRow('Year-to-Date Gross Receipts', '\u{20B9}${_formatAmount(_grossReceipts)}'),
              _infoRow('Estimated Expenses', '\u{20B9}${_formatAmount(_expenses)}'),
              _infoRow('Net Income', '\u{20B9}${_formatAmount(netIncome)}'),
              const Divider(height: 16),
              _infoRow('Deemed Profit (50%)', '\u{20B9}${_formatAmount(presumptiveTax)}'),
              if (isUnder44ada && isUnder50L)
                _infoRow('Tax Audit?', 'No (under \u{20B9}50L presumptive limit)', valueColor: AppColors.success)
              else if (!isUnder50L)
                _infoRow('Tax Audit?', 'YES — over \u{20B9}50L threshold', valueColor: AppColors.danger),
            ]),
          ),
          const SizedBox(height: 24),

          // Advance Tax Reminders
          _sectionChip('Advance Tax Schedule'),
          const SizedBox(height: 12),
          ...[
            {'date': '15 Jun', 'pct': '15%', 'label': '1st Instalment', 'due': DateTime(now.year, 6, 15)},
            {'date': '15 Sep', 'pct': '45%', 'label': '2nd Instalment', 'due': DateTime(now.year, 9, 15)},
            {'date': '15 Dec', 'pct': '75%', 'label': '3rd Instalment', 'due': DateTime(now.year, 12, 15)},
            {'date': '15 Mar', 'pct': '100%', 'label': '4th Instalment', 'due': DateTime(now.year + 1, 3, 15)},
          ].map((q) {
            final isPast = DateTime.now().isAfter(q['due'] as DateTime);
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isPast ? AppColors.bgCard.withOpacity(0.5) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isPast ? AppColors.borderLight.withOpacity(0.2) : AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: isPast ? AppColors.textMuted.withOpacity(0.15) : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(isPast ? Icons.check_circle : Icons.event, color: isPast ? AppColors.textMuted : AppColors.primaryLight, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(q['label'] as String, style: AppTypography.label(context).copyWith(
                    color: isPast ? AppColors.textMuted : AppColors.textPrimary,
                  )),
                  Text(q['date'] as String, style: AppTypography.bodySmall(context)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${q['pct']} (\u{20B9}${_formatAmount(advanceTaxEstimate * double.parse((q['pct'] as String).replaceAll('%', '')) / 100)})',
                      style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600)),
                ]),
              ]),
            );
          }),
          const SizedBox(height: 24),

          // GST Calendar
          _sectionChip('GST Filing Calendar'),
          const SizedBox(height: 12),
          if (_isGstRegistered) ...[
            _filingItem('GSTR-1 (Monthly)', '11th of next month', Icons.upload_file, AppColors.info),
            _filingItem('GSTR-3B (Monthly)', '20th of next month', Icons.description, AppColors.warning),
            const SizedBox(height: 8),
            if (_isExporting)
              _filingItem('LUT Renewal (Annual)', 'Before 31st March each year', Icons.refresh, AppColors.danger,
                  warning: 'Expired LUT silently forces 18% IGST on export invoices!'),
          ] else
            _infoCard('Not GST-registered. If you have inter-state clients, registration is mandatory regardless of turnover.'),
          const SizedBox(height: 24),

          // DTAA / Foreign Tax Credit
          _sectionChip('Foreign Tax Credit (Form 67)'),
          const SizedBox(height: 12),
          _infoCard('If foreign clients withheld tax abroad, log the amount and country here. '
              'This summary feeds directly into Form 67 (Foreign Tax Credit claim) — currently the single easiest '
              'foreign-income compliance step to forget. File within ITR due date.'),
          const SizedBox(height: 24),

          // Year-End Summary
          _sectionChip('Year-End Income Summary'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Column(children: [
              _infoRow('Total Gross Receipts', '\u{20B9}${_formatAmount(_grossReceipts)}'),
              _infoRow('GST Collected', '\u{20B9}${_formatAmount(_grossReceipts * 0.18)}', valueColor: AppColors.warning),
              _infoRow('TDS Expected (194J)', '\u{20B9}${_formatAmount(_grossReceipts * 0.10)}', valueColor: AppColors.info),
              const SizedBox(height: 8),
              Text('Hand this summary directly to your CA at filing time.',
                  style: AppTypography.bodySmall(context)),
            ]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/turnover-tracker'),
              icon: const Icon(Icons.trending_up, size: 18),
              label: const Text('Turnover Tracker — GST Threshold Monitor'),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  Widget _sectionChip(String title) {
    return Row(children: [
      Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(title, style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight)),
    ]);
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: AppTypography.body(context)),
        Text(value, style: AppTypography.body(context).copyWith(
          color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600,
        )),
      ]),
    );
  }

  Widget _filingItem(String title, String due, IconData icon, Color color, {String? warning}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: AppTypography.label(context))),
          Text(due, style: AppTypography.bodySmall(context)),
        ]),
        if (warning != null) ...[
          const SizedBox(height: 6),
          Text(warning, style: AppTypography.caption(context).copyWith(color: AppColors.danger)),
        ],
      ]),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard.withOpacity(0.5), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.2))),
      child: Text(text, style: AppTypography.body(context).copyWith(fontSize: 13)),
    );
  }

  String _formatAmount(double amt) {
    if (amt >= 10000000) return '${(amt / 10000000).toStringAsFixed(2)} Cr';
    if (amt >= 100000) return '${(amt / 100000).toStringAsFixed(2)} L';
    if (amt >= 1000) return '${(amt / 1000).toStringAsFixed(1)}K';
    return amt.toStringAsFixed(0);
  }
}
