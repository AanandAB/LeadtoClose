import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/contract.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  String _typeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final contracts = ref.watch(contractsProvider);
    final filtered = _typeFilter == 'all'
        ? contracts
        : contracts.where((c) => c.type == _typeFilter).toList();

    final activeCount = contracts.where((c) => c.status == 'active').length;
    final pendingCount =
        contracts.where((c) => c.status == 'draft' || c.status == 'sent').length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Contracts', style: AppTypography.displayMedium(context)),
              const Spacer(),
              StatChip(label: '$activeCount active', color: AppColors.success),
              const SizedBox(width: 8),
              StatChip(label: '$pendingCount pending', color: AppColors.warning),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Contract'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _typeButton('All', 'all'),
              _typeButton('SOW', 'SOW'),
              _typeButton('MSA', 'MSA'),
              _typeButton('NDA', 'NDA'),
              _typeButton('Retainer', 'retainer'),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.gavel_outlined,
                    title: 'No contracts yet',
                    subtitle: 'Create your first contract to get started',
                    actionLabel: 'New Contract',
                    onAction: () {},
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _buildContractCard(context, filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String label, String value) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _typeFilter = value),
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

  Widget _buildContractCard(BuildContext context, Contract contract) {
    final statusColor = AppTheme.statusColor(contract.status);

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
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.gavel, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contract.title.isNotEmpty ? contract.title : contract.number,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${contract.type} · ${DateFormat('MMM d, yyyy').format(contract.createdAt)}',
                  style: AppTypography.bodySmall(context),
                ),
              ],
            ),
          ),
          StatusChip(label: contract.status, color: statusColor),
        ],
      ),
    );
  }
}

class StatChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: AppTypography.caption(context).copyWith(
        color: color, fontWeight: FontWeight.w600,
      )),
    );
  }
}
