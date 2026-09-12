import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../models/client.dart';
import '../../models/project.dart';
import '../../models/lifecycle_checklist.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class PipelineScreen extends ConsumerStatefulWidget {
  const PipelineScreen({super.key});

  @override
  ConsumerState<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends ConsumerState<PipelineScreen> {
  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Pipeline', style: AppTypography.displayMedium(context)),
              const Spacer(),
              StatusChip(
                label: '${leads.length} leads',
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddLeadDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Lead'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Kanban Board
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalMinWidth = 7 * 180.0 + 6 * 12.0;
                final needsScroll = constraints.maxWidth < totalMinWidth;

                final board = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: LeadStage.values.map((stage) {
                    final stageLeads =
                        leads.where((l) => l.stage == stage).toList();
                    if (needsScroll) {
                      return SizedBox(
                        width: 180,
                        child: _buildColumn(context, stage, stageLeads),
                      );
                    } else {
                      return Expanded(
                        child: _buildColumn(context, stage, stageLeads),
                      );
                    }
                  }).toList(),
                );

                if (needsScroll) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: totalMinWidth,
                      child: board,
                    ),
                  );
                }
                return board;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumn(BuildContext context, LeadStage stage, List<Lead> leads) {
    final color = AppTheme.stageColor(stage.name);
    final isTerminalStage = stage == LeadStage.won || stage == LeadStage.lost;

    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  stage.name.replaceAll('_', ' ').toUpperCase(),
                  style: AppTypography.label(context).copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${leads.length}',
                    style: AppTypography.caption(context),
                  ),
                ),
              ],
            ),
          ),

          // Cards
          Container(
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgDeep,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                if (leads.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No leads',
                      style: AppTypography.bodySmall(context),
                    ),
                  ),
                ...leads.map((lead) => _buildLeadCard(context, lead)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    final isOverdue = lead.followUpDate != null && lead.isOverdue;

    return GestureDetector(
      onTap: () => _showLeadDetail(context, lead),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isOverdue
                ? AppColors.danger.withOpacity(0.3)
                : AppColors.borderLight.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Text(
                    lead.name[0].toUpperCase(),
                    style: AppTypography.label(context).copyWith(
                      color: AppColors.primaryLight,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: AppTypography.body(context).copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (lead.company.isNotEmpty)
                        Text(
                          lead.company,
                          style: AppTypography.caption(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                ScoreBadge(score: lead.score),
              ],
            ),
            if (lead.estimatedBudget > 0) ...[
              const SizedBox(height: 8),
              Text(
                AppCurrency.format(lead.estimatedBudget),
                style: AppTypography.label(context).copyWith(
                  color: AppColors.revenue,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 10, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d').format(lead.createdAt),
                  style: AppTypography.caption(context),
                ),
                if (isOverdue) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.warning_amber, size: 10, color: AppColors.danger),
                  const SizedBox(width: 4),
                  Text(
                    'Overdue',
                    style: AppTypography.caption(context).copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
                const Spacer(),
                if (lead.tags.isNotEmpty)
                  ...lead.tags.take(2).map((tag) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: AppTypography.caption(context).copyWith(
                            fontSize: 9,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String source = 'Direct';
    String serviceType = 'Website';
    String score = 'warm';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Lead', style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name *',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Estimated Budget',
                    prefixIcon: Icon(Icons.attach_money, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: source,
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    prefixIcon: Icon(Icons.source, size: 20),
                  ),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'Direct', child: Text('Direct')),
                    DropdownMenuItem(
                        value: 'Referral', child: Text('Referral')),
                    DropdownMenuItem(value: 'Upwork', child: Text('Upwork')),
                    DropdownMenuItem(
                        value: 'LinkedIn', child: Text('LinkedIn')),
                    DropdownMenuItem(value: 'Website', child: Text('Website')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => source = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: score,
                  decoration: const InputDecoration(
                    labelText: 'Score',
                    prefixIcon: Icon(Icons.star_outline, size: 20),
                  ),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'hot', child: Text('🔥 Hot')),
                    DropdownMenuItem(value: 'warm', child: Text('🌡 Warm')),
                    DropdownMenuItem(value: 'cold', child: Text('❄ Cold')),
                  ],
                  onChanged: (v) => score = v!,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: serviceType,
                  decoration: const InputDecoration(
                    labelText: 'Service Type',
                    prefixIcon: Icon(Icons.layers_outlined, size: 20),
                  ),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'Website', child: Text('Website')),
                    DropdownMenuItem(
                        value: 'Custom Software',
                        child: Text('Custom Software')),
                    DropdownMenuItem(value: 'Web App', child: Text('Web App')),
                  ],
                  onChanged: (v) => serviceType = v!,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Message / Requirements',
                    hintText: 'What does the client need?',
                    alignLabelWithHint: true,
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
              if (nameCtrl.text.trim().isEmpty) return;
              final lead = Lead(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                company: companyCtrl.text.trim(),
                source: source,
                serviceType: serviceType,
                score: score,
                estimatedBudget: double.tryParse(budgetCtrl.text) ?? 0,
                message: messageCtrl.text.trim(),
                stage: LeadStage.newLead,
              );
              ref.read(leadsProvider.notifier).addLead(lead);
              Navigator.pop(context);
            },
            child: const Text('Add Lead'),
          ),
        ],
      ),
    );
  }

  void _showLeadDetail(BuildContext context, Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => _LeadDetailSheet(
          lead: lead,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _LeadDetailSheet extends ConsumerWidget {
  final Lead lead;
  final ScrollController scrollController;

  const _LeadDetailSheet({
    required this.lead,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  lead.name[0].toUpperCase(),
                  style: AppTypography.heading1(context).copyWith(
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lead.name, style: AppTypography.heading1(context)),
                    if (lead.company.isNotEmpty)
                      Text(lead.company, style: AppTypography.body(context)),
                  ],
                ),
              ),
              StatusChip(
                label: lead.stageLabel,
                color: AppTheme.stageColor(lead.stageLabel),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Message (the original inquiry)
          if (lead.message.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Message',
                          style: AppTypography.label(context)
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(lead.message, style: AppTypography.body(context)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Contact + details
          Text('Details', style: AppTypography.heading3(context)),
          const SizedBox(height: 8),
          _detailRow(Icons.email_outlined, 'Email', lead.email),
          _detailRow(Icons.phone_outlined, 'Phone', lead.phone),
          _detailRow(Icons.source_outlined, 'Source', lead.source),
          if (lead.serviceType.isNotEmpty)
            _detailRow(Icons.layers_outlined, 'Service', lead.serviceType),
          if (lead.assignedTo.isNotEmpty)
            _detailRow(Icons.person_outline, 'Assigned to', lead.assignedTo),
          _detailRow(
              Icons.attach_money,
              'Budget',
              lead.estimatedBudget > 0
                  ? AppCurrency.format(lead.estimatedBudget)
                  : '—'),
          const SizedBox(height: 8),

          // Timeline
          _detailRow(Icons.event_available, 'Created',
              DateFormat('MMM d, yyyy').format(lead.createdAt)),
          _detailRow(Icons.schedule, 'Last contacted',
              DateFormat('MMM d, yyyy').format(lead.lastContactedAt)),
          if (lead.followUpDate != null)
            _detailRow(
              Icons.alarm,
              'Follow-up',
              '${DateFormat('MMM d, yyyy').format(lead.followUpDate!)}'
                  '${lead.isOverdue ? '  ·  Overdue' : ''}',
              valueColor: lead.isOverdue ? AppColors.danger : null,
            ),
          const SizedBox(height: 8),

          // Score
          Row(
            children: [
              Text('Score  ', style: AppTypography.body(context)),
              ScoreBadge(score: lead.score),
            ],
          ),
          const SizedBox(height: 8),

          // Tags
          if (lead.tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: lead.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(tag,
                            style: AppTypography.caption(context)
                                .copyWith(color: AppColors.primaryLight)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),

          // Stage change
          Text('Move to Stage', style: AppTypography.heading3(context)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LeadStage.values.map((stage) {
              final isSelected = lead.stage == stage;
              final color = AppTheme.stageColor(stage.name);
              return GestureDetector(
                onTap: isSelected
                    ? null
                    : () {
                        ref.read(leadsProvider.notifier).updateLead(
                              lead.copyWith(
                                stage: stage,
                                updatedAt: DateTime.now(),
                              ),
                            );
                        Navigator.pop(context);
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    stage.name.replaceAll('_', ' ').toUpperCase(),
                    style: AppTypography.label(context).copyWith(
                      color: isSelected ? color : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Notes (full history)
          if (lead.notes.isNotEmpty) ...[
            Text('Notes', style: AppTypography.heading3(context)),
            const SizedBox(height: 8),
            ...lead.notes.reversed.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.text, style: AppTypography.body(context)),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy · h:mm a')
                              .format(note.timestamp),
                          style: AppTypography.caption(context),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Activity timeline
          if (lead.activities.isNotEmpty) ...[
            Text('Activity', style: AppTypography.heading3(context)),
            const SizedBox(height: 8),
            ...lead.activities.reversed.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_activityIcon(a.type),
                            size: 14, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.description,
                                style: AppTypography.body(context)),
                            Text(
                              DateFormat('MMM d, yyyy · h:mm a')
                                  .format(a.timestamp),
                              style: AppTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
          ],

          // Actions
          const SizedBox(height: 24),
          if (lead.stage == LeadStage.won)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _convertToClient(context, ref, lead),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Convert to Client'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success),
              ),
            ),
          if (lead.stage == LeadStage.won) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      title: 'Delete Lead',
                      message: 'Are you sure you want to delete ${lead.name}?',
                    );
                    if (confirm) {
                      ref.read(leadsProvider.notifier).deleteLead(lead.id);
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _convertToClient(
      BuildContext context, WidgetRef ref, Lead lead) async {
    // Collect project details before converting (project name, service type,
    // budget). These seed the new Client, Project and lifecycle checklist.
    final projectNameCtrl = TextEditingController(
        text: lead.company.isNotEmpty ? lead.company : lead.name);
    final budgetCtrl = TextEditingController(
        text: lead.estimatedBudget > 0
            ? lead.estimatedBudget.toStringAsFixed(0)
            : '');
    String serviceType =
        lead.serviceType.isNotEmpty ? lead.serviceType : 'Custom Software';

    final submitted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Convert to Client & Project',
            style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: projectNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Project name *',
                    prefixIcon: Icon(Icons.folder_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: serviceType,
                  decoration: const InputDecoration(
                    labelText: 'Service type',
                    prefixIcon: Icon(Icons.layers_outlined, size: 20),
                  ),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'Website', child: Text('Website')),
                    DropdownMenuItem(
                        value: 'Custom Software',
                        child: Text('Custom Software')),
                    DropdownMenuItem(value: 'Web App', child: Text('Web App')),
                  ],
                  onChanged: (v) => serviceType = v!,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    prefixIcon: Icon(Icons.attach_money, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Convert'),
          ),
        ],
      ),
    );
    if (submitted != true) return;

    final projectName = projectNameCtrl.text.trim().isEmpty
        ? (lead.company.isNotEmpty ? lead.company : lead.name)
        : projectNameCtrl.text.trim();

    // 1) Create the client (as before).
    final client = Client(
      id: lead.id,
      companyName: lead.company.isNotEmpty ? lead.company : lead.name,
      contacts: [
        Contact(
          id: '1',
          name: lead.name,
          email: lead.email,
          phone: lead.phone,
          isPrimary: true,
        ),
      ],
      industry: '',
      healthScore: 'active',
      tags: lead.tags,
    );
    await ref.read(clientsProvider.notifier).addClient(client);

    // 2) Create the linked project. A client can hold multiple projects; each
    //    conversion creates one project (and one lifecycle checklist).
    final project = Project(
      id: 'proj_${lead.id}',
      name: projectName,
      clientId: client.id,
      description: lead.message.isNotEmpty ? lead.message : '',
      category: serviceType,
      budget: double.tryParse(budgetCtrl.text.trim()) ?? lead.estimatedBudget,
      tags: lead.tags,
    );
    await ref.read(projectsProvider.notifier).addProject(project);

    // 3) Auto-create the lifecycle checklist, keyed to the new project id.
    ref.read(checklistsProvider.notifier).ensureChecklist(
          id: project.id,
          track: ChecklistTrackX.fromCategory(serviceType),
          projectName: project.name,
        );

    // 4) The lead is now a client + project — remove it from the pipeline.
    ref.read(leadsProvider.notifier).deleteLead(lead.id);
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Converted — client, project & lifecycle checklist created'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// A labelled row for lead details. `valueColor` (optional) tints the value.
  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: Text(label,
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  )),
            ),
            Expanded(
              child: Text(
                value.isEmpty ? '—' : value,
                style: AppTypography.body(context).copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Maps a lead activity type string to a material icon.
  IconData _activityIcon(String type) {
    switch (type) {
      case 'email':
        return Icons.email_outlined;
      case 'call':
        return Icons.call_outlined;
      case 'meeting':
        return Icons.groups_outlined;
      case 'stage_change':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.notes_rounded;
    }
  }
}
