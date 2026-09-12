import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../models/lifecycle_checklist.dart';
import '../../providers.dart';
import '../../widgets/app_snackbars.dart';

/// Lifecycle Checklists — one screen, three separate tracks
/// (Website / Custom Software / Web App) with live progress persistence.
class ChecklistsScreen extends ConsumerStatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  ConsumerState<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends ConsumerState<ChecklistsScreen> {
  ChecklistTrack _selectedTrack = ChecklistTrack.website;
  String? _selectedInstanceId;
  String? _filterSeverity; // null | critical | required | recommended

  @override
  Widget build(BuildContext context) {
    final checklists = ref.watch(checklistsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lifecycle Checklists', style: AppTypography.heading2(context)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _trackSwitcher(),
                const SizedBox(height: 20),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: instances for the selected track
                      if (isWide)
                        SizedBox(
                          width: 300,
                          child: _instanceList(checklists),
                        ),
                      if (isWide) const SizedBox(width: 20),
                      Expanded(
                        child: _checklistDetail(
                          checklists,
                          compact: !isWide,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Track switcher ────────────────────────────────────────────────────────
  Widget _trackSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: ChecklistTrack.values.map((track) {
          final selected = track == _selectedTrack;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTrack = track;
                  _selectedInstanceId = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.16) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: selected
                      ? Border.all(color: AppColors.primary.withOpacity(0.5))
                      : null,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_trackIcon(track),
                            size: 16,
                            color: selected ? AppColors.primaryLight : AppColors.textMuted),
                        const SizedBox(width: 8),
                        Text(
                          track.label,
                          style: AppTypography.body(context).copyWith(
                            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _trackIcon(ChecklistTrack track) {
    switch (track) {
      case ChecklistTrack.website:
        return Icons.language_rounded;
      case ChecklistTrack.software:
        return Icons.memory_rounded;
      case ChecklistTrack.webapp:
        return Icons.cloud_queue_rounded;
    }
  }

  // ── Instance list (left pane) ────────────────────────────────────────────
  Widget _instanceList(List<ChecklistInstance> all) {
    final forTrack = all.where((c) => c.track == _selectedTrack).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text('${_selectedTrack.label} checklists',
                      style: AppTypography.body(context)
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  tooltip: 'New ${_selectedTrack.label} checklist',
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: AppColors.primaryLight,
                  onPressed: () => _createInstance(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: forTrack.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No ${_selectedTrack.label} checklists yet.\nCreate one to track a delivery.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall(context)
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: forTrack.length,
                    itemBuilder: (context, i) {
                      final c = forTrack[i];
                      final selected = c.id == _selectedInstanceId;
                      return ListTile(
                        selected: selected,
                        selectedTileColor: AppColors.primary.withOpacity(0.10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Text(
                          c.projectName,
                          style: AppTypography.body(context)
                              .copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: c.progress,
                              minHeight: 5,
                              backgroundColor: AppColors.borderLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                c.progress >= 1.0
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        trailing: Text(
                          '${c.doneCount}/${c.totalCount}',
                          style: AppTypography.caption(context)
                              .copyWith(color: AppColors.textMuted),
                        ),
                        onTap: () =>
                            setState(() => _selectedInstanceId = c.id),
                        onLongPress: () => _confirmDelete(c),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _createInstance() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New ${_selectedTrack.label} checklist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
              labelText: 'Project / client name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final instance = ref.read(checklistsProvider.notifier).ensureChecklist(
          id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
          track: _selectedTrack,
          projectName: name,
        );
    setState(() => _selectedInstanceId = instance.id);
  }

  Future<void> _confirmDelete(ChecklistInstance c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete checklist?'),
        content: Text('Remove "${c.projectName}" and its progress?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      ref.read(checklistsProvider.notifier).deleteChecklist(c.id);
      if (_selectedInstanceId == c.id) _selectedInstanceId = null;
    }
  }

  // ── Checklist detail (right pane) ────────────────────────────────────────
  Widget _checklistDetail(List<ChecklistInstance> all, {required bool compact}) {
    ChecklistInstance? instance = all
        .where((c) => c.id == _selectedInstanceId)
        .firstOrNull;

    if (instance == null) {
      // Auto-pick the first instance on this track, if any.
      final forTrack =
          all.where((c) => c.track == _selectedTrack).toList();
      if (forTrack.isNotEmpty && !compact) instance = forTrack.first;
    }

    if (instance == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_trackIcon(_selectedTrack),
                size: 44, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              '${_selectedTrack.label} lifecycle checklist',
              style: AppTypography.heading2(context),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedTrack.description,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(context)
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _createInstance,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create checklist'),
            ),
          ],
        ),
      );
    }

    final template = instance.template;
    final criticalPending = template.phases
        .expand((p) => p.items)
        .where((i) =>
            i.severity == ChecklistSeverity.critical &&
            instance!.checked[i.id] != true)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // Header with live progress
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instance.projectName,
                          style: AppTypography.heading2(context)),
                      const SizedBox(height: 4),
                      Text(
                        '${instance.doneCount}/${instance.totalCount} items complete'
                        '${criticalPending > 0 ? '  •  $criticalPending critical pending' : ''}',
                        style: AppTypography.bodySmall(context).copyWith(
                          color: criticalPending > 0
                              ? Colors.orangeAccent
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                // Severity filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: _filterSeverity,
                    hint: Text('All severities',
                        style: AppTypography.bodySmall(context)),
                    dropdownColor: AppColors.bgCard,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...ChecklistSeverity.values.map((s) => DropdownMenuItem(
                            value: s.name,
                            child: Text(s.label),
                          )),
                    ],
                    onChanged: (v) => setState(() => _filterSeverity = v),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0),
            ),
            child: LinearProgressIndicator(
              value: instance.progress,
              minHeight: 4,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                instance.progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: template.phases.length,
              itemBuilder: (context, pi) {
                final phase = template.phases[pi];
                return _phaseCard(instance!, phase);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _phaseCard(ChecklistInstance instance, ChecklistPhaseDef phase) {
    final items = phase.items
        .where((i) =>
            _filterSeverity == null || i.severity.name == _filterSeverity)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final doneCount =
        items.where((i) => instance.checked[i.id] == true).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgMid.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          title: Row(
            children: [
              Expanded(
                child: Text(phase.phase.label,
                    style: AppTypography.body(context)
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
              Text('$doneCount/${items.length}',
                  style: AppTypography.caption(context)
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
          children: items.map((item) => _itemTile(instance, item)).toList(),
        ),
      ),
    );
  }

  Widget _itemTile(ChecklistInstance instance, ChecklistItemDef item) {
    final done = instance.checked[item.id] == true;

    return CheckboxListTile(
      value: done,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        item.title,
        style: AppTypography.body(context).copyWith(
          color: done ? AppColors.textMuted : AppColors.textPrimary,
          decoration: done ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: item.detail.isEmpty
          ? null
          : Text(item.detail,
              style:
                  AppTypography.caption(context).copyWith(color: AppColors.textMuted)),
      secondary: _severityChip(item.severity),
      activeColor: AppColors.success,
      onChanged: (_) => ref
          .read(checklistsProvider.notifier)
          .toggleItem(instance.id, item.id),
    );
  }

  Widget _severityChip(ChecklistSeverity severity) {
    Color color;
    switch (severity) {
      case ChecklistSeverity.critical:
        color = Colors.redAccent;
        break;
      case ChecklistSeverity.required:
        color = Colors.orangeAccent;
        break;
      case ChecklistSeverity.recommended:
        color = AppColors.info;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        severity.label,
        style: AppTypography.caption(context)
            .copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
