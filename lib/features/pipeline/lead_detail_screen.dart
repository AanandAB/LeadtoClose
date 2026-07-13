
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../models/project_profile.dart';
import '../../models/quote.dart';
import '../../providers.dart';
import '../../services/storage_service.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final String leadId;
  const LeadDetailScreen({super.key, required this.leadId});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> {
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);
    final lead = leads.where((l) => l.id == widget.leadId).firstOrNull;

    if (lead == null) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard'))),
        body: const Center(child: Text('Lead not found')),
      );
    }

    final hasDiscovery = lead.projectProfile != null;
    final quotes = ref.watch(quotesProvider(widget.leadId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        title: Text(lead.name, style: AppTypography.heading2(context)),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') {
                _confirmDelete(lead);
              } else {
                final updated = lead.copyWith(stage: v, lastActivity: DateTime.now());
                ref.read(leadsProvider.notifier).updateLead(updated);
              }
            },
            itemBuilder: (context) => [
              ...StorageService.pipelineStages.map((s) => PopupMenuItem(value: s, child: Text(s))),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Lead Info Card
            _infoCard(lead),
            const SizedBox(height: 24),

            // Action buttons
            Row(children: [
              if (!hasDiscovery)
                _actionButton('Discovery', Icons.quiz_outlined, AppColors.primary,
                    () => context.go('/lead/${lead.id}/discovery')),
              if (!hasDiscovery) const SizedBox(width: 12),
              if (hasDiscovery)
                _actionButton('Compliance', Icons.verified_outlined, AppColors.success,
                    () => context.go('/lead/${lead.id}/compliance')),
              const SizedBox(width: 12),
              if (hasDiscovery)
                _actionButton(quotes.isEmpty ? 'Generate Quote' : 'Quote', Icons.description_outlined, AppColors.info,
                    () => context.go('/lead/${lead.id}/quote')),
              if (quotes.isNotEmpty) ...[
                const SizedBox(width: 12),
                _actionButton('Contract', Icons.gavel, AppColors.warning,
                    () => context.go('/lead/${lead.id}/contract')),
                const SizedBox(width: 12),
                _actionButton('Invoice', Icons.receipt_long, AppColors.success,
                    () => context.go('/lead/${lead.id}/invoice')),
                const SizedBox(width: 12),
                _actionButton('Messages', Icons.chat, AppColors.info,
                    () => context.go('/lead/${lead.id}/messages')),
              ],
            ]),
            const SizedBox(height: 8),

            // Discovery status
            if (hasDiscovery) ...[
              const SizedBox(height: 24),
              _discoverySummary(lead.projectProfile!),
            ],

            // Quotes
            if (quotes.isNotEmpty) ...[
              const SizedBox(height: 24),
              _quotesSection(quotes),
            ],

            // Notes
            const SizedBox(height: 24),
            _notesSection(lead),
          ]),
        ),
      ),
    );
  }

  Widget _infoCard(Lead lead) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Text(lead.name[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primaryLight, fontSize: 20, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lead.name, style: AppTypography.heading2(context)),
            if (lead.company.isNotEmpty) Text(lead.company, style: AppTypography.body(context)),
          ])),
          _stageBadge(lead.stage),
        ]),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(children: [
          _infoChip(Icons.contact_mail, lead.contact.isNotEmpty ? lead.contact : 'No contact'),
          const SizedBox(width: 16),
          _infoChip(Icons.source, lead.source),
          const SizedBox(width: 16),
          _infoChip(Icons.calendar_today, DateFormat('dd MMM yyyy').format(lead.createdAt)),
        ]),
      ]),
    );
  }

  Widget _stageBadge(String stage) {
    final isWon = stage == 'Won';
    final isLost = stage == 'Lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isWon ? AppColors.success.withOpacity(0.15) :
               isLost ? AppColors.danger.withOpacity(0.15) :
               AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(stage, style: AppTypography.label(context).copyWith(
        color: isWon ? AppColors.success : isLost ? AppColors.danger : AppColors.primaryLight,
      )),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(text, style: AppTypography.bodySmall(context)),
    ]);
  }

  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }

  Widget _discoverySummary(ProjectProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text('Discovery Complete', style: AppTypography.label(context).copyWith(color: AppColors.success)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: [
          _summaryChip('Type', profile.projectType),
          _summaryChip('Tier', profile.projectTier),
          _summaryChip('Client', profile.clientLocation),
          _summaryChip('IP', profile.ipOwnership),
          if (profile.requiresHosting) _summaryChip('Hosting', profile.hostingType),
          if (profile.acceptsPayments) _summaryChip('Payments', profile.paymentType),
        ]),
      ]),
    );
  }

  Widget _summaryChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $value', style: AppTypography.caption(context)),
    );
  }

  Widget _quotesSection(List<Quote> quotes) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quotes', style: AppTypography.heading2(context)),
      const SizedBox(height: 8),
      ...quotes.map((q) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.description, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Quote v${q.version}', style: AppTypography.label(context).copyWith(color: AppColors.textPrimary)),
            Text('${q.lineItems.length} items · ${q.gstTreatment}', style: AppTypography.bodySmall(context)),
          ])),
          Text('\u{20B9}${q.total.toStringAsFixed(0)}', style: AppTypography.price(context)),
        ]),
      )),
    ]);
  }

  Widget _notesSection(Lead lead) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Activity Log', style: AppTypography.heading2(context)),
      const SizedBox(height: 12),
      ...lead.notes.reversed.map((note) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(DateFormat('dd/MM HH:mm').format(note.timestamp),
              style: AppTypography.caption(context)),
          const SizedBox(width: 12),
          Expanded(child: Text(note.text, style: AppTypography.body(context).copyWith(color: AppColors.textPrimary))),
        ]),
      )),
      if (lead.notes.isEmpty)
        Text('No activity yet', style: AppTypography.bodySmall(context)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _noteCtrl,
            style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Add a note...',
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onSubmitted: (_) => _addNote(lead),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _addNote(lead),
          icon: const Icon(Icons.send, color: AppColors.primaryLight),
        ),
      ]),
    ]);
  }

  void _addNote(Lead lead) {
    if (_noteCtrl.text.trim().isEmpty) return;
    final updated = lead.copyWith(
      lastActivity: DateTime.now(),
      notes: [...lead.notes, LeadNote(text: _noteCtrl.text.trim(), timestamp: DateTime.now())],
    );
    ref.read(leadsProvider.notifier).updateLead(updated);
    _noteCtrl.clear();
  }

  void _confirmDelete(Lead lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Delete ${lead.name}? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(leadsProvider.notifier).deleteLead(lead.id);
              Navigator.pop(ctx);
              context.go('/dashboard');
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
