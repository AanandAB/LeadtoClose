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
              StatChip(
                  label: '$pendingCount pending', color: AppColors.warning),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showCreateContractDialog(context),
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
                    onAction: () => _showCreateContractDialog(context),
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
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : Colors.transparent,
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
            width: 44,
            height: 44,
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
                  contract.title.isNotEmpty
                      ? contract.title
                      : contract.number,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(label: contract.status, color: statusColor),
              if (contract.expiresAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Expires ${DateFormat('MMM d, yyyy').format(contract.expiresAt!)}',
                  style: AppTypography.caption(context),
                ),
              ],
            ],
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
            onSelected: (v) => _handleContractAction(v, contract),
            itemBuilder: (_) => [
              if (contract.status == 'draft')
                const PopupMenuItem(value: 'send', child: Text('Mark as Sent')),
              if (contract.status == 'sent')
                const PopupMenuItem(value: 'sign', child: Text('Mark as Signed')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ],
      ),
    );
  }

  void _handleContractAction(String action, Contract contract) {
    if (action == 'send') {
      ref.read(contractsProvider.notifier).updateContract(contract.copyWith(status: 'sent'));
      return;
    }
    if (action == 'sign') {
      ref.read(contractsProvider.notifier).updateContract(contract.copyWith(status: 'active', signedAt: DateTime.now()));
      return;
    }
    if (action == 'delete') {
      ref.read(contractsProvider.notifier).deleteContract(contract.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contract deleted'),
            action: SnackBarAction(label: 'Undo', onPressed: () {
              ref.read(contractsProvider.notifier).addContract(contract);
            }),
          ),
        );
      }
    }
  }

  void _showCreateContractDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final signerNameCtrl = TextEditingController();
    final signerEmailCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String contractType = 'SOW';
    String? selectedClientId;
    final clauses = <_ClauseEntry>[
      _ClauseEntry('Scope of Work', ''),
      _ClauseEntry('Payment Terms', ''),
      _ClauseEntry('Confidentiality', ''),
      _ClauseEntry('Termination', ''),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title:
              Text('New Contract', style: AppTypography.heading2(context)),
          content: SizedBox(
            width: 550,
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contract type
                  DropdownButtonFormField<String>(
                    value: contractType,
                    decoration: const InputDecoration(
                      labelText: 'Contract Type',
                      prefixIcon: Icon(Icons.description_outlined, size: 20),
                    ),
                    dropdownColor: AppColors.bgCard,
                    items: const [
                      DropdownMenuItem(value: 'SOW', child: Text('Statement of Work')),
                      DropdownMenuItem(value: 'MSA', child: Text('Master Service Agreement')),
                      DropdownMenuItem(value: 'NDA', child: Text('Non-Disclosure Agreement')),
                      DropdownMenuItem(value: 'retainer', child: Text('Retainer Agreement')),
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    ],
                    onChanged: (v) =>
                        setDialogState(() => contractType = v!),
                  ),
                  const SizedBox(height: 12),

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

                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contract Title *',
                      prefixIcon: Icon(Icons.title, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Signer info
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: signerNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Signer Name',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: signerEmailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Signer Email',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Clauses
                  Row(
                    children: [
                      Text('Clauses',
                          style: AppTypography.heading2(context)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => setDialogState(
                            () => clauses.add(_ClauseEntry('', ''))),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Clause'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(clauses.length, (i) {
                    final clause = clauses[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: clause.titleCtrl,
                                  decoration: InputDecoration(
                                    hintText: 'Clause Title',
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                              if (clauses.length > 3)
                                IconButton(
                                  onPressed: () =>
                                      setDialogState(() => clauses.removeAt(i)),
                                  icon: Icon(Icons.remove_circle_outline,
                                      color: AppColors.danger, size: 20),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: clause.bodyCtrl,
                            maxLines: 2,
                            decoration: InputDecoration(
                              hintText: 'Clause content...',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
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
                      labelText: 'Additional Notes',
                      hintText: 'Special terms, conditions...',
                    ),
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

                final contractClauses = clauses
                    .where((c) => c.titleCtrl.text.isNotEmpty)
                    .map((c) => ContractClause(
                          title: c.titleCtrl.text,
                          body: c.bodyCtrl.text,
                          category: 'standard',
                        ))
                    .toList();

                final contract = Contract(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  number:
                      'CTR-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
                  clientId: selectedClientId ?? '',
                  title: titleCtrl.text.trim(),
                  type: contractType,
                  clauses: contractClauses,
                  status: 'draft',
                  signerName: signerNameCtrl.text.trim(),
                  signerEmail: signerEmailCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                  expiresAt: DateTime.now().add(const Duration(days: 365)),
                );

                ref.read(contractsProvider.notifier).addContract(contract);
                Navigator.pop(ctx);
              },
              child: const Text('Create Contract'),
            ),
          ],
        ),
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
      child: Text(label,
          style: AppTypography.caption(context).copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}

class _ClauseEntry {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  _ClauseEntry(String title, String body) {
    titleCtrl.text = title;
    bodyCtrl.text = body;
  }
}
