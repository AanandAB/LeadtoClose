
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/invoice.dart';
import '../../providers.dart';
import '../../services/invoice_service.dart';

class InvoiceScreen extends ConsumerStatefulWidget {
  final String leadId;
  const InvoiceScreen({super.key, required this.leadId});

  @override
  ConsumerState<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends ConsumerState<InvoiceScreen> {
  Invoice? _invoice;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateInvoice());
  }

  void _generateInvoice() {
    try {
      final leads = ref.read(leadsProvider);
      final lead = leads.firstWhere((l) => l.id == widget.leadId);
      final profile = ref.read(businessProfileProvider);
      final quotes = ref.read(quotesProvider(widget.leadId));

      if (lead.projectProfile == null || quotes.isEmpty || profile == null) {
        setState(() { _error = 'Complete discovery and generate a quote first.'; _loading = false; });
        return;
      }

      final service = InvoiceService();
      final invoice = service.generateInvoice(
        leadId: widget.leadId, quote: quotes.first,
        profile: lead.projectProfile!, businessProfile: profile, lead: lead,
      );

      setState(() { _invoice = invoice; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
      body: const Center(child: CircularProgressIndicator()),
    );

    if (_error.isNotEmpty) return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
      body: Center(child: Text(_error, style: AppTypography.body(context))),
    );

    final inv = _invoice!;
    final symbol = inv.currency == 'USD' ? '\$' : '\u{20B9}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Invoice ${inv.number}', style: AppTypography.heading2(context)),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'Export PDF', onPressed: () => _exportPdf()),
        ],
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
            ),
            child: Column(children: [
              Row(children: [
                _statusBadge(inv.status),
                const Spacer(),
                Text(inv.number, style: AppTypography.heading2(context)),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _metaCol('Date', _fmt(inv.createdAt)),
                _metaCol('Due Date', _fmt(inv.dueDate), isWarning: inv.isOverdue),
                _metaCol('SAC', inv.sacCode),
                _metaCol('GST', inv.gstTreatment),
              ]),
              if (inv.isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.warning, color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Text('${inv.daysOverdue} days overdue', style: AppTypography.label(context).copyWith(color: AppColors.danger)),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          // Line items
          Text('Services', style: AppTypography.heading2(context)),
          const SizedBox(height: 8),
          ...inv.lineItems.map((item) => _lineItemRow(item, symbol)),
          const SizedBox(height: 16),

          // Totals
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primary.withOpacity(0.2))),
            child: Column(children: [
              _totalRow('Subtotal', '$symbol${inv.subtotal.toStringAsFixed(0)}'),
              const SizedBox(height: 4),
              _totalRow('GST', '$symbol${inv.gstAmount.toStringAsFixed(0)}', muted: true),
              const Divider(height: 20),
              _totalRow('TOTAL', '$symbol${inv.total.toStringAsFixed(0)}', bold: true),
              if (inv.expectedTdsAmount > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Column(children: [
                    _totalRow('Expected TDS (10% u/s 194J)', '-$symbol${inv.expectedTdsAmount.toStringAsFixed(0)}', warning: true),
                    const SizedBox(height: 4),
                    _totalRow('Expected Net Receipt', '$symbol${(inv.total - inv.expectedTdsAmount).toStringAsFixed(0)}', bold: true),
                  ]),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          // GST Breakdown
          if (inv.gstAmount > 0) ...[
            Text('GST Breakdown', style: AppTypography.heading2(context)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight.withOpacity(0.2))),
              child: Column(children: [
                if (inv.cgstRate > 0) _totalRow('CGST @ ${inv.cgstRate.toStringAsFixed(0)}%', '$symbol${(inv.subtotal * inv.cgstRate / 100).toStringAsFixed(0)}', muted: true),
                if (inv.sgstRate > 0) _totalRow('SGST @ ${inv.sgstRate.toStringAsFixed(0)}%', '$symbol${(inv.subtotal * inv.sgstRate / 100).toStringAsFixed(0)}', muted: true),
                if (inv.igstRate > 0) _totalRow('IGST @ ${inv.igstRate.toStringAsFixed(0)}%', '$symbol${(inv.subtotal * inv.igstRate / 100).toStringAsFixed(0)}', muted: true),
              ]),
            ),
          ],
          const SizedBox(height: 24),

          // Actions
          Row(children: [
            Expanded(child: SizedBox(height: 48, child: ElevatedButton.icon(
              onPressed: () => _exportPdf(),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('Export PDF'),
            ))),
            const SizedBox(width: 12),
            Expanded(child: SizedBox(height: 48, child: OutlinedButton.icon(
              onPressed: () => context.go('/lead/${widget.leadId}/payment'),
              icon: const Icon(Icons.payments, size: 18),
              label: const Text('Payment Tracking'),
            ))),
          ]),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: AppTypography.caption(context).copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
    );
  }

  Widget _metaCol(String label, String value, {bool isWarning = false}) {
    return Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTypography.caption(context)),
      Text(value, style: AppTypography.label(context).copyWith(
        color: isWarning ? AppColors.danger : AppColors.textPrimary,
      )),
    ]));
  }

  Widget _lineItemRow(InvoiceLineItem item, String symbol) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(child: Text(item.description, style: AppTypography.body(context).copyWith(color: AppColors.textPrimary))),
        Text('$symbol${item.amount.toStringAsFixed(0)}', style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _totalRow(String label, String value, {bool muted = false, bool bold = false, bool warning = false}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: (bold ? AppTypography.heading2(context) : AppTypography.body(context)).copyWith(
        color: warning ? AppColors.warning : muted ? AppColors.textMuted : AppColors.textPrimary,
      )),
      Text(value, style: AppTypography.price(context).copyWith(
        fontSize: bold ? 20 : 14,
        color: warning ? AppColors.warning : AppColors.success,
      )),
    ]);
  }

  void _exportPdf() async {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final profile = ref.read(businessProfileProvider);
    if (profile == null || _invoice == null) return;
    await InvoiceService().exportPdf(invoice: _invoice!, lead: lead, profile: profile);
  }

  String _fmt(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month-1]} ${dt.year}';
  }
}
