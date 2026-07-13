
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/compliance_item.dart';
import '../../providers.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  final String leadId;
  const ChecklistScreen({super.key, required this.leadId});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  late List<ComplianceItem> _items;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChecklist();
    });
  }

  void _loadChecklist() {
    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    if (lead.projectProfile != null) {
      ref.read(currentProjectProfileProvider.notifier).state = lead.projectProfile;
      setState(() {
        _items = ref.read(complianceChecklistProvider);
        _loaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final byCategory = <ComplianceCategory, List<ComplianceItem>>{};
    for (final item in _items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    final done = _items.where((i) => i.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Compliance Checklist', style: AppTypography.heading2(context)),
      ),
      body: Column(children: [
        // Progress
        Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.primaryDark.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: CircularProgressIndicator(
                    value: _items.isEmpty ? 0 : done / _items.length,
                    strokeWidth: 4,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    backgroundColor: AppColors.bgSurface,
                  ),
                ),
                Text('$done', style: AppTypography.label(context).copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$done of ${_items.length} complete', style: AppTypography.heading2(context).copyWith(fontSize: 16)),
                Text('Complete all items before generating contract', style: AppTypography.bodySmall(context)),
              ]),
            ),
          ]),
        ),

        // Items
        Expanded(
          child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            ...byCategory.entries.map((entry) => _categorySection(entry.key, entry.value)),
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
          child: SizedBox(
            width: double.infinity, height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/lead/${widget.leadId}/quote'),
              child: const Text('Generate Quote'),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _categorySection(ComplianceCategory category, List<ComplianceItem> items) {
    final icon = _categoryIcon(category);
    final color = _categoryColor(category);
    final label = items.first.categoryLabel;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTypography.label(context).copyWith(color: color, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text('(${items.where((i) => i.isCompleted).length}/${items.length})',
            style: AppTypography.bodySmall(context)),
      ]),
      const SizedBox(height: 8),
      ...items.map((item) => _checklistTile(item)),
    ]);
  }

  Widget _checklistTile(ComplianceItem item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          final idx = _items.indexWhere((i) => i.id == item.id);
          if (idx >= 0) {
            _items[idx] = _items[idx].copyWith(isCompleted: !_items[idx].isCompleted);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isCompleted ? AppColors.success.withOpacity(0.05) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: item.isCompleted ? AppColors.success.withOpacity(0.2) : AppColors.borderLight.withOpacity(0.2),
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 22, height: 22,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: item.isCompleted ? AppColors.success : AppColors.textMuted, width: 2),
              color: item.isCompleted ? AppColors.success : Colors.transparent,
            ),
            child: item.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.title, style: AppTypography.body(context).copyWith(
                color: item.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
              )),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(item.description, style: AppTypography.bodySmall(context)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  IconData _categoryIcon(ComplianceCategory cat) {
    switch (cat) {
      case ComplianceCategory.build: return Icons.build;
      case ComplianceCategory.contract: return Icons.description;
      case ComplianceCategory.advisory: return Icons.lightbulb;
      case ComplianceCategory.invoicing: return Icons.receipt_long;
    }
  }

  Color _categoryColor(ComplianceCategory cat) {
    switch (cat) {
      case ComplianceCategory.build: return AppColors.info;
      case ComplianceCategory.contract: return AppColors.warning;
      case ComplianceCategory.advisory: return AppColors.primaryLight;
      case ComplianceCategory.invoicing: return AppColors.success;
    }
  }
}
