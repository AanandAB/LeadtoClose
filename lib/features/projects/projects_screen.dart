import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/project.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _view = 'kanban';

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final active = projects.where((p) => p.status == ProjectStatus.active).length;
    final completed = projects.where((p) => p.status == ProjectStatus.completed).length;
    final overdueCount = projects.where((p) => p.isOverdue).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Projects', style: AppTypography.displayMedium(context)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    _viewBtn('kanban', Icons.view_kanban_rounded),
                    _viewBtn('list', Icons.list_rounded),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddProjectDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Project'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              StatCard(label: 'Active', value: '$active', color: AppColors.info, icon: Icons.play_circle_outline),
              const SizedBox(width: 16),
              StatCard(label: 'Completed', value: '$completed', color: AppColors.success, icon: Icons.check_circle_outline),
              const SizedBox(width: 16),
              StatCard(label: 'Overdue', value: '$overdueCount', color: AppColors.danger, icon: Icons.warning_amber),
              const SizedBox(width: 16),
              StatCard(label: 'Total', value: '${projects.length}', color: AppColors.primary, icon: Icons.folder_outlined),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: projects.isEmpty
                ? EmptyState(
                    icon: Icons.folder_outlined,
                    title: 'No projects yet',
                    subtitle: 'Create your first project to get started',
                    actionLabel: 'New Project',
                    onAction: () => _showAddProjectDialog(context),
                  )
                : _view == 'kanban'
                    ? _buildKanbanView(projects)
                    : _buildListView(projects),
          ),
        ],
      ),
    );
  }

  Widget _viewBtn(String view, IconData icon) {
    final selected = _view == view;
    return GestureDetector(
      onTap: () => setState(() => _view = view),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: selected ? AppColors.primaryLight : AppColors.textMuted),
      ),
    );
  }

  Widget _buildKanbanView(List<Project> projects) {
    final statuses = [
      (ProjectStatus.planning, 'Planning', AppColors.textMuted),
      (ProjectStatus.active, 'Active', AppColors.info),
      (ProjectStatus.onHold, 'On Hold', AppColors.warning),
      (ProjectStatus.completed, 'Completed', AppColors.success),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((s) {
        final statusProjects = projects.where((p) => p.status == s.$1).toList();
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: s.$3.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: s.$3),
                      ),
                      const SizedBox(width: 8),
                      Text('${s.$2} (${statusProjects.length})',
                        style: AppTypography.label(context).copyWith(color: s.$3)),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 100),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgDeep,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: statusProjects.isEmpty
                        ? [Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('No projects', style: AppTypography.bodySmall(context)),
                          )]
                        : statusProjects.map((p) => _buildProjectCard(p)).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectCard(Project project) {
    final progress = project.budget > 0 ? (project.spent / project.budget).clamp(0.0, 1.0) : 0.0;

    return GestureDetector(
      onTap: () => context.go('/project/${project.id}'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name, style: AppTypography.body(context).copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13,
          )),
          if (project.dueDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 10,
                    color: project.isOverdue ? AppColors.danger : AppColors.textMuted),
                const SizedBox(width: 4),
                Text(DateFormat('MMM d').format(project.dueDate!),
                    style: AppTypography.caption(context).copyWith(
                      color: project.isOverdue ? AppColors.danger : null,
                    )),
              ],
            ),
          ],
          if (project.budget > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress, minHeight: 4,
                backgroundColor: AppColors.bgCard,
                valueColor: AlwaysStoppedAnimation(
                  progress > 0.9 ? AppColors.danger : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('\$${project.spent.toStringAsFixed(0)} / \$${project.budget.toStringAsFixed(0)}',
                style: AppTypography.caption(context)),
          ],
        ],
      ),
    ),
    );
  }

  Widget _buildListView(List<Project> projects) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, i) {
        final p = projects[i];
        final statusColor = AppTheme.statusColor(p.status.name);
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
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name, style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 2),
                    Text(p.description.isNotEmpty ? p.description : 'No description',
                        style: AppTypography.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Budget', style: AppTypography.caption(context)),
                    Text('\$${p.budget.toStringAsFixed(0)}',
                        style: AppTypography.label(context)),
                  ],
                ),
              ),
              Expanded(
                child: p.dueDate != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Due', style: AppTypography.caption(context)),
                          Text(DateFormat('MMM d').format(p.dueDate!),
                              style: AppTypography.label(context)),
                        ],
                      )
                    : const SizedBox(),
              ),
              StatusChip(label: p.status.name, color: statusColor),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                onSelected: (v) => _handleProjectAction(v, p),
                itemBuilder: (_) => [
                  if (p.status != ProjectStatus.completed)
                    const PopupMenuItem(value: 'complete', child: Text('Mark as Completed')),
                  if (p.status != ProjectStatus.active)
                    const PopupMenuItem(value: 'activate', child: Text('Mark as Active')),
                  const PopupMenuDivider(),
                  PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Project', style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Project Name *')),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                TextField(controller: budgetCtrl, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Budget')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                  ],
                  onChanged: (v) => priority = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final project = Project(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameCtrl.text.trim(),
                clientId: '',
                description: descCtrl.text.trim(),
                budget: double.tryParse(budgetCtrl.text) ?? 0,
                priority: priority,
                status: ProjectStatus.planning,
              );
              ref.read(projectsProvider.notifier).addProject(project);
              Navigator.pop(ctx);
            },
            child: const Text('Create Project'),
          ),
        ],
      ),
    );
  }

  void _handleProjectAction(String action, Project project) {
    switch (action) {
      case 'complete':
        ref.read(projectsProvider.notifier).updateProject(project.copyWith(status: ProjectStatus.completed));
        break;
      case 'activate':
        ref.read(projectsProvider.notifier).updateProject(project.copyWith(status: ProjectStatus.active));
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Project'),
            content: const Text('Are you sure you want to delete this project?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  ref.read(projectsProvider.notifier).deleteProject(project.id);
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
}
