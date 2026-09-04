import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/quote.dart';
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
                onPressed: () {},
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
                value: '\$${_formatNum(totalValue)}',
                color: AppColors.info,
                icon: Icons.description_outlined,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Accepted',
                value: '\$${_formatNum(acceptedValue)}',
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Pending',
                value: '\$${_formatNum(pendingValue)}',
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
                    onAction: () {},
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
                '\$${quote.total.toStringAsFixed(0)}',
                style: AppTypography.price(context).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              StatusChip(
                label: quote.status,
                color: statusColor,
                isSmall: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNum(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
