
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../models/contract.dart';
import '../../providers.dart';
import '../../services/contract_service.dart';

class ContractScreen extends ConsumerStatefulWidget {
  final String leadId;
  const ContractScreen({super.key, required this.leadId});

  @override
  ConsumerState<ContractScreen> createState() => _ContractScreenState();
}

class _ContractScreenState extends ConsumerState<ContractScreen> {
  Contract? _contract;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateContract());
  }

  void _generateContract() {
    try {
      final leads = ref.read(leadsProvider);
      final lead = leads.firstWhere((l) => l.id == widget.leadId);
      final profile = ref.read(businessProfileProvider);
      final quotes = ref.read(quotesProvider(widget.leadId));

      if (lead.projectProfile == null || quotes.isEmpty || profile == null) {
        setState(() { _error = 'Complete discovery and generate a quote first.'; _loading = false; });
        return;
      }

      final contractService = ContractService();
      final contract = contractService.generateContract(
        leadId: widget.leadId, quote: quotes.first,
        profile: lead.projectProfile!, businessProfile: profile, lead: lead,
      );

      // Add note to lead
      final updated = lead.copyWith(
        lastActivity: DateTime.now(),
        notes: [...lead.notes, LeadNote(text: 'Contract generated.', timestamp: DateTime.now())],
      );
      ref.read(leadsProvider.notifier).updateLead(updated);

      setState(() { _contract = contract; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
        body: Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.warning_amber, size: 48, color: AppColors.warning),
          const SizedBox(height: 16),
          Text(_error, style: AppTypography.body(context), textAlign: TextAlign.center),
        ]))),
      );
    }

    final contract = _contract!;
    final standardClauses = contract.clauses.where((c) => c.category == 'standard').toList();
    final conditionalClauses = contract.clauses.where((c) => c.category == 'conditional').toList();
    final disclaimer = contract.clauses.where((c) => c.category == 'disclaimer').firstOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Agreement', style: AppTypography.heading2(context)),
        actions: [
          IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'Export PDF', onPressed: () => _exportPdf()),
        ],
      ),
      body: Column(children: [
        // Summary header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppColors.bgMid,
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description, color: AppColors.primaryLight, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Service Agreement', style: AppTypography.heading2(context).copyWith(fontSize: 16)),
              Text('${contract.clauses.length} clauses · ${conditionalClauses.length} conditional', style: AppTypography.bodySmall(context)),
            ])),
            _statusBadge(contract.status),
          ]),
        ),

        // Clauses
        Expanded(
          child: ListView(padding: const EdgeInsets.all(20), children: [
            // Standard clauses
            _sectionHeader('Standard Clauses', Icons.checklist, AppColors.info),
            const SizedBox(height: 8),
            ...standardClauses.map((c) => _clauseCard(c, false)),

            // Conditional clauses
            if (conditionalClauses.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionHeader('Conditional Clauses', Icons.rule, AppColors.warning),
              const SizedBox(height: 4),
              Text('Inserted based on your project profile', style: AppTypography.bodySmall(context)),
              const SizedBox(height: 8),
              ...conditionalClauses.map((c) => _clauseCard(c, true)),
            ],

            // Disclaimer
            if (disclaimer != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.warning_amber, color: AppColors.danger, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(disclaimer.body, style: AppTypography.bodySmall(context).copyWith(color: AppColors.danger))),
                ]),
              ),
            ],
            const SizedBox(height: 100),
          ]),
        ),

        // Bottom bar
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            border: Border(top: BorderSide(color: AppColors.borderLight.withOpacity(0.3))),
          ),
          child: Row(children: [
            Expanded(
              child: SizedBox(height: 48, child: ElevatedButton.icon(
                onPressed: () => _exportPdf(),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Export PDF'),
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(height: 48, child: OutlinedButton.icon(
                onPressed: () => _exportPdf(),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
              )),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text(title, style: AppTypography.label(null).copyWith(color: color)),
    ]);
  }

  Widget _clauseCard(ContractClause clause, bool isConditional) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isConditional
            ? AppColors.warning.withOpacity(0.2)
            : AppColors.borderLight.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(clause.title, style: AppTypography.body(null).copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        )),
        subtitle: isConditional && clause.trigger != 'Always'
            ? Text('Trigger: ${clause.trigger}', style: AppTypography.caption(null).copyWith(color: AppColors.warning))
            : null,
        children: [Text(clause.body, style: AppTypography.body(null).copyWith(fontSize: 13))],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: AppTypography.caption(null).copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.w700)),
    );
  }

  void _exportPdf() async {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final profile = ref.read(businessProfileProvider);
    if (profile == null || _contract == null) return;
    final contractService = ContractService();
    await contractService.exportPdf(contract: _contract!, lead: lead, profile: profile);
  }
}
