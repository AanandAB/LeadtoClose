
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../models/quote.dart';
import '../../providers.dart';

class QuoteScreen extends ConsumerStatefulWidget {
  final String leadId;
  const QuoteScreen({super.key, required this.leadId});

  @override
  ConsumerState<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends ConsumerState<QuoteScreen> {
  Quote? _currentQuote;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initQuote());
  }

  void _initQuote() {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final quotes = ref.read(quotesProvider(widget.leadId));

    if (lead.projectProfile == null) {
      context.go('/lead/${widget.leadId}');
      return;
    }

    if (quotes.isNotEmpty) {
      setState(() { _currentQuote = quotes.first; _loading = false; });
    } else {
      _generateQuote(lead);
    }
  }

  void _generateQuote(Lead lead) {
    final profile = lead.projectProfile!;
    final complianceItems = ref.read(complianceChecklistProvider);
    final isGstRegistered = (ref.read(businessProfileProvider)?.isGstRegistered ?? false);
    final quoteService = ref.read(quoteServiceProvider);

    final quote = quoteService.generateQuote(
      leadId: widget.leadId, profile: profile,
      complianceItems: complianceItems, isGstRegistered: isGstRegistered,
    );

    setState(() { _currentQuote = quote; _loading = false; });
    ref.read(quotesProvider(widget.leadId).notifier).saveQuote(quote);

    // Update lead stage
    final updated = lead.copyWith(
      stage: 'Quote Sent', lastActivity: DateTime.now(),
      notes: [...lead.notes, LeadNote(text: 'Quote v1 generated.', timestamp: DateTime.now())],
    );
    ref.read(leadsProvider.notifier).updateLead(updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final quote = _currentQuote!;
    final profile = ref.read(businessProfileProvider);
    final currencySymbol = quote.gstTreatment == 'Zero-Rated (Export)' ? '\$' : '\u{20B9}';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Quote v${quote.version}', style: AppTypography.heading2(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF',
            onPressed: () => _exportPdf(quote),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Quote',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(profile?.businessName ?? 'Your Business', style: AppTypography.heading2(context)),
                      if (profile != null) ...[
                        const SizedBox(height: 4),
                        Text(profile.email, style: AppTypography.bodySmall(context)),
                        if (profile.gstin.isNotEmpty)
                          Text('GSTIN: ${profile.gstin}', style: AppTypography.caption(context)),
                      ],
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(quote.status.toUpperCase(), style: AppTypography.caption(context).copyWith(
                      color: AppColors.primaryLight, fontWeight: FontWeight.w700,
                    )),
                  ),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(children: [
                  _metaColumn('Date', _formatDate(quote.createdAt)),
                  _metaColumn('SAC Code', quote.sacCode),
                  _metaColumn('GST', quote.gstTreatment),
                ]),
              ]),
            ),
            const SizedBox(height: 24),

            // Line Items
            Text('Services', style: AppTypography.heading2(context)),
            const SizedBox(height: 12),
            ...quote.lineItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight.withOpacity(0.2)),
              ),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.description, style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(4)),
                    child: Text(item.category, style: AppTypography.caption(context).copyWith(fontSize: 9)),
                  ),
                ])),
                Text('$currencySymbol${item.amount.toStringAsFixed(0)}',
                  style: AppTypography.body(context).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              ]),
            )),
            const SizedBox(height: 20),

            // Totals
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(children: [
                _totalRow('Subtotal', '$currencySymbol${quote.subtotal.toStringAsFixed(0)}', false),
                const SizedBox(height: 6),
                _totalRow('GST (${quote.gstTreatment})', '$currencySymbol${quote.gstAmount.toStringAsFixed(0)}', false),
                const Divider(height: 20),
                _totalRow('TOTAL', '$currencySymbol${quote.total.toStringAsFixed(0)}', true),
              ]),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _exportPdf(quote),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: const Text('Export PDF'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Quote'),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _metaColumn(String label, String value) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.caption(context)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.label(context).copyWith(color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _totalRow(String label, String amount, bool bold) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: (bold ? AppTypography.heading2(context) : AppTypography.body(context)).copyWith(
        color: bold ? AppColors.textPrimary : AppColors.textSecondary,
      )),
      Text(amount, style: AppTypography.price(context).copyWith(
        fontSize: bold ? 24 : 16,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
      )),
    ]);
  }

  void _exportPdf(Quote quote) async {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final profile = ref.read(businessProfileProvider);
    if (profile == null) return;
    final pdfService = ref.read(pdfServiceProvider);
    await pdfService.exportQuote(quote: quote, lead: lead, profile: profile);
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month-1]} ${dt.year}';
  }
}
