import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/project.dart';
import '../../models/task.dart';
import '../../models/invoice.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  String _view = 'kanban';

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final project = projects.where((p) => p.id == widget.projectId).firstOrNull;

    if (project == null) {
      return Scaffold(
        body: Center(child: Text('Project not found', style: AppTypography.body(context))),
      );
    }

    final tasks = ref.watch(tasksProvider).where((t) => t.projectId == project.id).toList();
    final timeEntries = ref.watch(timeEntriesProvider).where((t) => t.projectId == project.id).toList();
    final projectInvoices = ref.watch(invoicesProvider).where((i) => i.clientId == project.clientId).toList();
    final totalHours = timeEntries.fold(0.0, (s, e) => s + e.hours);
    final billableHours = timeEntries.where((e) => e.isBillable).fold(0.0, (s, e) => s + e.hours);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name, style: AppTypography.heading2(context)),
            Text(project.description.isNotEmpty ? project.description : 'No description',
                style: AppTypography.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          // View toggle
          Container(
            margin: const EdgeInsets.only(right: 8),
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
          StatusChip(
            label: project.status.name,
            color: AppTheme.statusColor(project.status.name),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Main content
          Expanded(
            child: Column(
              children: [
                // Stats bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      _statPill('Tasks', '${tasks.length}', AppColors.info),
                      _statPill('Done', '${tasks.where((t) => t.status == TaskStatus.done).length}', AppColors.success),
                      _statPill('Hours', '${totalHours.toStringAsFixed(1)}h', AppColors.primary),
                      _statPill('Billable', '${billableHours.toStringAsFixed(1)}h', AppColors.success),
                      if (project.budget > 0) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('${AppCurrency.format(project.spent)} / ${AppCurrency.format(project.budget)}',
                                      style: AppTypography.caption(context)),
                                  const Spacer(),
                                  Text('${project.budgetPercentage.toStringAsFixed(0)}%',
                                      style: AppTypography.caption(context)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (project.spent / project.budget).clamp(0.0, 1.0),
                                  minHeight: 4,
                                  backgroundColor: AppColors.bgSurface,
                                  valueColor: AlwaysStoppedAnimation(
                                    project.budgetPercentage > 90 ? AppColors.danger : AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Task board
                Expanded(
                  child: _view == 'kanban' ? _buildKanban(tasks) : _buildList(tasks, project.id),
                ),
              ],
            ),
          ),

          // Right sidebar - Project info
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              border: Border(left: BorderSide(color: AppColors.borderLight)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Project Info', style: AppTypography.label(context).copyWith(
                  color: AppColors.textMuted, letterSpacing: 0.5,
                )),
                const SizedBox(height: 12),
                _infoRow('Status', project.status.name),
                _infoRow('Priority', project.priority),
                if (project.dueDate != null)
                  _infoRow('Due Date', DateFormat('MMM d, yyyy').format(project.dueDate!)),
                if (project.startDate != null)
                  _infoRow('Start Date', DateFormat('MMM d, yyyy').format(project.startDate!)),
                if (project.budget > 0) ...[
                  _infoRow('Budget', AppCurrency.format(project.budget)),
                  _infoRow('Spent', AppCurrency.format(project.spent)),
                ],
                const SizedBox(height: 16),

                // Add task button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTaskDialog(context, project.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Task'),
                  ),
                ),
                const SizedBox(height: 16),

                // Milestones placeholder
                Text('Milestones', style: AppTypography.label(context).copyWith(
                  color: AppColors.textMuted, letterSpacing: 0.5,
                )),
                const SizedBox(height: 8),
                Text('No milestones yet', style: AppTypography.bodySmall(context)),
                const SizedBox(height: 20),

                // Invoices section
                Row(
                  children: [
                    Text('Invoices', style: AppTypography.label(context).copyWith(
                      color: AppColors.textMuted, letterSpacing: 0.5,
                    )),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showCreateInvoiceForProject(context, project),
                      child: Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (projectInvoices.isEmpty)
                  Text('No invoices yet', style: AppTypography.bodySmall(context)),
                ...projectInvoices.map((inv) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 14, color: AppTheme.statusColor(inv.status)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(inv.number, style: AppTypography.bodySmall(context))),
                      Text(AppCurrency.format(inv.total), style: AppTypography.label(context).copyWith(fontSize: 11)),
                    ],
                  ),
                )),
              ],
            ),
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
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: selected ? AppColors.primaryLight : AppColors.textMuted),
      ),
    );
  }

  Widget _statPill(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(
        children: [
          Text('$label: ', style: AppTypography.caption(context)),
          Text(value, style: AppTypography.label(context).copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildKanban(List<Task> tasks) {
    final statuses = [
      (TaskStatus.todo, 'To Do', AppColors.textMuted),
      (TaskStatus.inProgress, 'In Progress', AppColors.info),
      (TaskStatus.review, 'Review', AppColors.warning),
      (TaskStatus.done, 'Done', AppColors.success),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((s) {
        final columnTasks = tasks.where((t) => t.status == s.$1).toList();
        return Expanded(
          child: Container(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                      Text('${s.$2} (${columnTasks.length})',
                          style: AppTypography.label(context).copyWith(color: s.$3)),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bgDeep,
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: columnTasks.isEmpty
                        ? Center(child: Text('No tasks', style: AppTypography.bodySmall(context)))
                        : ListView.builder(
                            itemCount: columnTasks.length,
                            itemBuilder: (context, i) => _buildTaskCard(columnTasks[i]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildList(List<Task> tasks, String projectId) {
    if (tasks.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.task_alt,
          title: 'No tasks yet',
          subtitle: 'Add your first task to get started',
          actionLabel: 'Add Task',
          onAction: () => _showAddTaskDialog(context, projectId),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, i) => _buildTaskListItem(tasks[i]),
    );
  }

  Widget _buildTaskCard(Task task) {
    final priorityColor = AppTheme.priorityColor(task.priority);

    return GestureDetector(
      onTap: () => _showTaskActions(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4, height: 4,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: priorityColor),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(task.title, style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 12,
                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 10, color: task.isOverdue ? AppColors.danger : AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM d').format(task.dueDate!),
                      style: AppTypography.caption(context).copyWith(
                        color: task.isOverdue ? AppColors.danger : null,
                      )),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaskListItem(Task task) {
    final statusColor = AppTheme.statusColor(task.status.name);
    final priorityColor = AppTheme.priorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // Status checkbox
          GestureDetector(
            onTap: () {
              final nextStatus = _nextStatus(task.status);
              ref.read(tasksProvider.notifier).updateTask(
                    task.copyWith(status: nextStatus),
                  );
            },
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.status == TaskStatus.done ? AppColors.success : AppColors.textMuted,
                  width: 2,
                ),
                color: task.status == TaskStatus.done ? AppColors.success : Colors.transparent,
              ),
              child: task.status == TaskStatus.done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppTypography.body(context).copyWith(
                  color: task.status == TaskStatus.done ? AppColors.textMuted : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                )),
                if (task.description.isNotEmpty)
                  Text(task.description, style: AppTypography.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),

          // Priority
          PriorityChip(priority: task.priority, isSmall: true),

          // Due date
          if (task.dueDate != null) ...[
            const SizedBox(width: 12),
            Text(DateFormat('MMM d').format(task.dueDate!),
                style: AppTypography.caption(context).copyWith(
                  color: task.isOverdue ? AppColors.danger : null,
                )),
          ],

          // Actions
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') {
                ref.read(tasksProvider.notifier).deleteTask(task.id);
              } else {
                final status = TaskStatus.values.firstWhere((s) => s.name == v);
                ref.read(tasksProvider.notifier).updateTask(task.copyWith(status: status));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'todo', child: Text('Move to To Do')),
              const PopupMenuItem(value: 'inProgress', child: Text('Move to In Progress')),
              const PopupMenuItem(value: 'review', child: Text('Move to Review')),
              const PopupMenuItem(value: 'done', child: Text('Mark Done')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
            child: Icon(Icons.more_horiz, size: 16, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  TaskStatus _nextStatus(TaskStatus current) {
    switch (current) {
      case TaskStatus.todo: return TaskStatus.inProgress;
      case TaskStatus.inProgress: return TaskStatus.review;
      case TaskStatus.review: return TaskStatus.done;
      case TaskStatus.done: return TaskStatus.todo;
    }
  }

  void _showTaskActions(Task task) {
    // Could show a detail sheet - for now just cycle status
  }

  void _showAddTaskDialog(BuildContext context, String projectId) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Task', style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  prefixIcon: Icon(Icons.task_alt, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined, size: 20),
                ),
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              final task = Task(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                projectId: projectId,
                title: titleCtrl.text.trim(),
                description: descCtrl.text.trim(),
                priority: priority,
              );
              ref.read(tasksProvider.notifier).addTask(task);
              Navigator.pop(ctx);
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: AppTypography.caption(context))),
          Expanded(child: Text(value, style: AppTypography.body(context).copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w500, fontSize: 13,
          ))),
        ],
      ),
    );
  }

  void _showCreateInvoiceForProject(BuildContext context, Project project) {
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String currency = AppCurrency.code;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('New Invoice for ${project.name}', style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined, size: 20)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount', prefixText: AppCurrency.symbol, prefixIcon: const Icon(Icons.attach_money, size: 20)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (descCtrl.text.trim().isEmpty) return;
              final amount = double.tryParse(priceCtrl.text) ?? 0;
              final invoice = Invoice(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                number: 'INV-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
                clientId: project.clientId,
                projectId: project.id,
                status: 'active',
                lineItems: [InvoiceLineItem(description: descCtrl.text.trim(), quantity: 1, rate: amount)],
                subtotal: amount, total: amount, currency: currency,
                paymentTerms: 'Net 30',
                dueDate: DateTime.now().add(const Duration(days: 30)),
              );
              ref.read(invoicesProvider.notifier).addInvoice(invoice);
              Navigator.pop(ctx);
            },
            child: const Text('Create Invoice'),
          ),
        ],
      ),
    );
  }
}
