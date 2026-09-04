import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/invoice.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final invoices = ref.watch(invoicesProvider);
    final filtered = _statusFilter == 'all'
        ? invoices
        : invoices.where((i) => i.status == _statusFilter).toList();

    final totalRevenue = invoices
        .where((i) => i.status == 'paid')
        .fold(0.0, (s, i) => s + i.total);
    final outstanding = invoices
        .where((i) => i.status != 'paid' && i.status != 'cancelled')
        .fold(0.0, (s, i) => s + i.balanceDue);
    final overdue = invoices
        .where((i) => i.isOverdue)
        .fold(0.0, (s, i) => s + i.balanceDue);
    final paidCount = invoices.where((i) => i.status == 'paid').length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Invoices', style: AppTypography.displayMedium(context)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCreateInvoiceDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Invoice'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatCard(
                  label: 'Paid',
                  value: _fmt(totalRevenue),
                  color: AppColors.success,
                  icon: Icons.check_circle_outline),
              const SizedBox(width: 16),
              StatCard(
                  label: 'Outstanding',
                  value: _fmt(outstanding),
                  color: AppColors.warning,
                  icon: Icons.schedule_rounded),
              const SizedBox(width: 16),
              StatCard(
                  label: 'Overdue',
                  value: _fmt(overdue),
                  color: AppColors.danger,
                  icon: Icons.warning_amber),
              const SizedBox(width: 16),
              StatCard(
                  label: 'Paid Count',
                  value: '$paidCount',
                  color: AppColors.info,
                  icon: Icons.receipt_long),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _filterBtn('All', 'all'),
              _filterBtn('Draft', 'draft'),
              _filterBtn('Sent', 'sent'),
              _filterBtn('Paid', 'paid'),
              _filterBtn('Overdue', 'overdue'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No invoices yet',
                    subtitle: 'Create your first invoice to get started',
                    actionLabel: 'New Invoice',
                    onAction: () => _showCreateInvoiceDialog(context),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _buildInvoiceCard(context, filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterBtn(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color:
                selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.borderLight),
          ),
          child: Text(label,
              style: AppTypography.label(context).copyWith(
                color:
                    selected ? AppColors.primaryLight : AppColors.textMuted,
                fontSize: 12,
              )),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final statusColor = AppTheme.statusColor(invoice.status);
    final symbol = AppCurrency.symbol;

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
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long, color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.number,
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(
                  'Due ${DateFormat('MMM d, yyyy').format(invoice.dueDate)} · ${invoice.paymentTerms}',
                  style: AppTypography.bodySmall(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$symbol${invoice.total.toStringAsFixed(0)}',
                  style:
                      AppTypography.price(context).copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(
                      label: invoice.status,
                      color: statusColor,
                      isSmall: true),
                  if (invoice.isOverdue) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${invoice.daysOverdue}d late',
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.danger,
                            fontSize: 9,
                          )),
                    ),
                  ],
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                    onSelected: (v) => _handleInvoiceAction(v, invoice),
                    itemBuilder: (_) => [
                      if (invoice.status == 'draft')
                        const PopupMenuItem(value: 'send', child: Text('Mark as Sent')),
                      if (invoice.status != 'paid')
                        const PopupMenuItem(value: 'paid', child: Text('Mark as Paid')),
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

  void _handleInvoiceAction(String action, Invoice invoice) {
    switch (action) {
      case 'send':
        ref.read(invoicesProvider.notifier).updateInvoice(invoice.copyWith(status: 'sent'));
        break;
      case 'paid':
        ref.read(invoicesProvider.notifier).updateInvoice(invoice.copyWith(status: 'paid', amountPaid: invoice.total));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Invoice'),
            content: const Text('Are you sure you want to delete this invoice?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  ref.read(invoicesProvider.notifier).deleteInvoice(invoice.id);
                  Navigator.pop(ctx);
                },
                child: Text('Delete', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );
        break;
    }
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    final notesCtrl = TextEditingController();
    String selectedCurrency = AppCurrency.code;
    String paymentTerms = 'Net 30';
    String status = 'draft';
    String? selectedClientId;
    final items = <_InvoiceLineItem>[_InvoiceLineItem()];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('New Invoice', style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 500,
            height: 450,
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
                          labelText: 'Client *',
                          prefixIcon: Icon(Icons.business_outlined, size: 20),
                        ),
                        dropdownColor: AppColors.bgCard,
                        items: clients
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.companyName),
                                ))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedClientId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Currency and payment terms
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCurrency,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                          ),
                          dropdownColor: AppColors.bgCard,
                          items: const [
                            DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                            DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                            DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                            DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => selectedCurrency = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: paymentTerms,
                          decoration: const InputDecoration(
                            labelText: 'Payment Terms',
                          ),
                          dropdownColor: AppColors.bgCard,
                          items: const [
                            DropdownMenuItem(
                                value: 'Net 15', child: Text('Net 15')),
                            DropdownMenuItem(
                                value: 'Net 30', child: Text('Net 30')),
                            DropdownMenuItem(
                                value: 'Net 45', child: Text('Net 45')),
                            DropdownMenuItem(
                                value: 'Net 60', child: Text('Net 60')),
                            DropdownMenuItem(
                                value: 'Due on Receipt',
                                child: Text('Due on Receipt')),
                          ],
                          onChanged: (v) =>
                              setDialogState(() => paymentTerms = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Line items
                  Row(
                    children: [
                      Text('Line Items',
                          style: AppTypography.heading2(context)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setDialogState(
                            () => items.add(_InvoiceLineItem())),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(items.length, (i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
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
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
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

                  // Notes
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Payment instructions, thank you note...',
                    ),
                  ),

                  // Total preview
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      double total = 0;
                      for (final item in items) {
                        final qty = double.tryParse(item.qtyCtrl.text) ?? 0;
                        final price =
                            double.tryParse(item.priceCtrl.text) ?? 0;
                        total += qty * price;
                      }
                      final prevCode = AppCurrency.code;
                      AppCurrency.setCode(selectedCurrency);
                      final totalText = AppCurrency.formatDecimal(total);
                      AppCurrency.setCode(prevCode);
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total', style: AppTypography.heading2(context)),
                            Text(totalText,
                                style: AppTypography.heading2(context)
                                    .copyWith(color: AppColors.primary)),
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
                if (selectedClientId == null) return;

                final lineItems = items
                    .where((item) => item.descCtrl.text.isNotEmpty)
                    .map((item) => InvoiceLineItem(
                          description: item.descCtrl.text,
                          quantity:
                              double.tryParse(item.qtyCtrl.text) ?? 1,
                          rate:
                              double.tryParse(item.priceCtrl.text) ?? 0,
                        ))
                    .toList();

                final total = lineItems.fold(
                    0.0,
                    (sum, item) =>
                        sum + item.quantity * item.rate);

                final invoice = Invoice(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  number:
                      'INV-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
                  clientId: selectedClientId ?? '',

                  status: status,
                  lineItems: lineItems,
                  subtotal: total,
                  taxRate: 0,
                  taxAmount: 0,
                  total: total,
                  currency: selectedCurrency,
                  paymentTerms: paymentTerms,
                  dueDate: DateTime.now().add(const Duration(days: 30)),
                  notes: notesCtrl.text.trim(),
                );

                ref.read(invoicesProvider.notifier).addInvoice(invoice);
                Navigator.pop(ctx);
              },
              child: const Text('Create Invoice'),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    return AppCurrency.formatCompact(v);
  }
}

class _InvoiceLineItem {
  final descCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
}
