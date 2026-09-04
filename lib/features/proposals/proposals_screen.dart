import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/quote.dart';
import '../../models/client.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ProposalsScreen extends ConsumerStatefulWidget {
  const ProposalsScreen({super.key});

  @override
  ConsumerState<ProposalsScreen> createState() => _ProposalsScreenState();
}

class _ProposalsScreenState extends ConsumerState<ProposalsScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final quotes = ref.watch(quotesProvider);
    final filtered = _statusFilter == 'all'
        ? quotes
        : quotes.where((q) => q.status == _statusFilter).toList();

    final totalValue = quotes.fold(0.0, (sum, q) => sum + q.total);
    final acceptedValue = quotes
        .where((q) => q.status == 'accepted')
        .fold(0.0, (sum, q) => sum + q.total);
    final pendingValue = quotes
        .where((q) => q.status == 'sent')
        .fold(0.0, (sum, q) => sum + q.total);
    final winRate = quotes.isNotEmpty
        ? (quotes.where((q) => q.status == 'accepted').length /
                quotes.length *
                100)
            .toStringAsFixed(0)
        : '0';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Proposals', style: AppTypography.displayMedium(context)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateProposalDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Proposal'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              StatCard(
                label: 'Total Value',
                value: _formatNum(totalValue),
                color: AppColors.info,
                icon: Icons.description_outlined,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Accepted',
                value: _formatNum(acceptedValue),
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Pending',
                value: _formatNum(pendingValue),
                color: AppColors.warning,
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Win Rate',
                value: '$winRate%',
                color: AppColors.primary,
                icon: Icons.trending_up,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              _filterButton('All', 'all'),
              _filterButton('Draft', 'draft'),
              _filterButton('Sent', 'sent'),
              _filterButton('Accepted', 'accepted'),
              _filterButton('Rejected', 'rejected'),
            ],
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.description_outlined,
                    title: 'No proposals yet',
                    subtitle: 'Create your first proposal to get started',
                    actionLabel: 'New Proposal',
                    onAction: () => _showCreateProposalDialog(context),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _buildQuoteCard(context, filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.label(context).copyWith(
              color: selected ? AppColors.primaryLight : AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, Quote quote) {
    final statusColor = AppTheme.statusColor(quote.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.description_outlined,
                color: AppColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote.title.isNotEmpty ? quote.title : quote.number,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${quote.lineItems.length} items · ${DateFormat('MMM d, yyyy').format(quote.createdAt)}',
                  style: AppTypography.bodySmall(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppCurrency.format(quote.total),
                style: AppTypography.price(context).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(
                    label: quote.status,
                    color: statusColor,
                    isSmall: true,
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                    onSelected: (v) => _handleQuoteAction(v, quote),
                    itemBuilder: (_) => [
                      if (quote.status == 'draft')
                        const PopupMenuItem(value: 'send', child: Text('Mark as Sent')),
                      if (quote.status == 'sent') ...[
                        const PopupMenuItem(value: 'accept', child: Text('Mark as Accepted')),
                        const PopupMenuItem(value: 'reject', child: Text('Mark as Rejected')),
                      ],
                      const PopupMenuDivider(),
                      PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleQuoteAction(String action, Quote quote) async {
    switch (action) {
      case 'send':
        ref.read(quotesProvider.notifier).updateQuote(quote.copyWith(status: 'sent'));
        break;
      case 'accept':
        ref.read(quotesProvider.notifier).updateQuote(quote.copyWith(status: 'accepted'));
        break;
      case 'reject':
        ref.read(quotesProvider.notifier).updateQuote(quote.copyWith(status: 'rejected'));
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Delete Proposal'),
            content: const Text('Are you sure you want to delete this proposal? This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
        if (confirmed == true && mounted) {
          await ref.read(quotesProvider.notifier).deleteQuote(quote.id);
        }
        break;
    }
  }

  void _showCreateProposalDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final items = <_LineItemEntry>[_LineItemEntry()];
    String? selectedClientId;
    double taxRate = 0.0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('New Proposal', style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 550,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client selection
                  Consumer(
                    builder: (context, ref, _) {
                      final clients = ref.watch(clientsProvider);
                      return DropdownButtonFormField<String>(
                        value: selectedClientId,
                        decoration: const InputDecoration(
                          labelText: 'Client',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                        dropdownColor: AppColors.bgCard,
                        items: clients
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.companyName),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setDialogState(() => selectedClientId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Proposal Title *',
                      prefixIcon: Icon(Icons.title, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Line items
                  Row(
                    children: [
                      Text('Line Items',
                          style: AppTypography.heading2(context)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setDialogState(
                            () => items.add(_LineItemEntry())),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(items.length, (i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: item.descCtrl,
                              decoration: InputDecoration(
                                hintText: 'Description',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: item.qtyCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Qty',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: item.priceCtrl,
                              keyboardType:
                                  TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Price',
                                prefixText: AppCurrency.symbol,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          if (items.length > 1)
                            IconButton(
                              onPressed: () =>
                                  setDialogState(() => items.removeAt(i)),
                              icon: Icon(Icons.remove_circle_outline,
                                  color: AppColors.danger, size: 20),
                            ),
                        ],
                      ),
                    );
                  }),

                  // Tax rate
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Tax Rate: ', style: AppTypography.body(context)),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '0',
                            suffixText: '%',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onChanged: (v) => setDialogState(
                              () => taxRate = double.tryParse(v) ?? 0.0),
                        ),
                      ),
                    ],
                  ),

                  // Total preview
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, _) {
                      double subtotal = 0;
                      for (final item in items) {
                        final qty = double.tryParse(item.qtyCtrl.text) ?? 0;
                        final price =
                            double.tryParse(item.priceCtrl.text) ?? 0;
                        subtotal += qty * price;
                      }
                      final tax = subtotal * taxRate / 100;
                      final total = subtotal + tax;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Subtotal',
                                    style: AppTypography.body(context)),
                                Text(AppCurrency.formatDecimal(subtotal),
                                    style: AppTypography.body(context)),
                              ],
                            ),
                            if (taxRate > 0)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tax (${taxRate.toStringAsFixed(1)}%)',
                                      style: AppTypography.body(context)),
                                  Text(AppCurrency.formatDecimal(tax),
                                      style: AppTypography.body(context)),
                                ],
                              ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total',
                                    style: AppTypography.heading2(context)),
                                Text(AppCurrency.formatDecimal(total),
                                    style: AppTypography.heading2(context)
                                        .copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;

                final lineItems = items
                    .where((item) => item.descCtrl.text.isNotEmpty)
                    .map((item) => LineItem(
                          id: DateTime.now().millisecondsSinceEpoch
                              .toString(),
                          description: item.descCtrl.text,
                          quantity:
                              double.tryParse(item.qtyCtrl.text) ?? 1,
                          unitPrice:
                              double.tryParse(item.priceCtrl.text) ?? 0,
                        ))
                    .toList();

                final subtotal = lineItems.fold(
                    0.0,
                    (sum, item) =>
                        sum + item.quantity * item.unitPrice);
                final tax = subtotal * taxRate / 100;

                final quote = Quote(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  number:
                      'PROP-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
                  title: titleCtrl.text.trim(),
                  clientId: selectedClientId ?? '',
                  status: 'draft',
                  lineItems: lineItems.map((li) => QuoteLineItem(
                    id: li.id,
                    description: li.description,
                    quantity: li.quantity,
                    rate: li.unitPrice,
                  )).toList(),
                  subtotal: subtotal,
                  taxRate: taxRate,
                  taxAmount: tax,
                  total: subtotal + tax,
                  createdAt: DateTime.now(),
                  validUntil: '30 days',
                  notes: descCtrl.text.trim(),
                );

                ref.read(quotesProvider.notifier).addQuote(quote);
                Navigator.pop(ctx);
              },
              child: const Text('Create Proposal'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNum(double v) {
    return AppCurrency.formatCompact(v);
  }
}

class _LineItemEntry {
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
}

class LineItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  LineItem({required this.id, required this.description, this.quantity = 1, this.unitPrice = 0});
}
