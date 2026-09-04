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

    final totalRevenue = invoices.where((i) => i.status == 'paid').fold(0.0, (s, i) => s + i.total);
    final outstanding = invoices.where((i) => i.status != 'paid' && i.status != 'cancelled').fold(0.0, (s, i) => s + i.balanceDue);
    final overdue = invoices.where((i) => i.isOverdue).fold(0.0, (s, i) => s + i.balanceDue);
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
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Invoice'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              StatCard(label: 'Paid', value: '\$${_fmt(totalRevenue)}', color: AppColors.success, icon: Icons.check_circle_outline),
              const SizedBox(width: 16),
              StatCard(label: 'Outstanding', value: '\$${_fmt(outstanding)}', color: AppColors.warning, icon: Icons.schedule_rounded),
              const SizedBox(width: 16),
              StatCard(label: 'Overdue', value: '\$${_fmt(overdue)}', color: AppColors.danger, icon: Icons.warning_amber),
              const SizedBox(width: 16),
              StatCard(label: 'Paid Count', value: '$paidCount', color: AppColors.info, icon: Icons.receipt_long),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              _filterBtn('All', 'all'), _filterBtn('Draft', 'draft'),
              _filterBtn('Sent', 'sent'), _filterBtn('Paid', 'paid'),
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
                    actionLabel: 'New Invoice', onAction: () {},
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _buildInvoiceCard(context, filtered[i]),
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
            color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
          ),
          child: Text(label, style: AppTypography.label(context).copyWith(
            color: selected ? AppColors.primaryLight : AppColors.textMuted, fontSize: 12,
          )),
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, Invoice invoice) {
    final statusColor = AppTheme.statusColor(invoice.status);
    final symbol = invoice.currency == 'USD' ? '\$' : invoice.currency == 'EUR' ? '€' : '£';

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
            width: 44, height: 44,
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
                Text(invoice.number, style: AppTypography.body(context).copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600,
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
                  style: AppTypography.price(context).copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(label: invoice.status, color: statusColor, isSmall: true),
                  if (invoice.isOverdue) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${invoice.daysOverdue}d late',
                          style: AppTypography.caption(context).copyWith(
                            color: AppColors.danger, fontSize: 9,
                          )),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
