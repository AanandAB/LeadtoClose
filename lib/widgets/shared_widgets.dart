import 'package:flutter/material.dart';
import '../core/theme.dart';

// ============ Stat Card ============
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodySmall(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.statValue(context).copyWith(color: color),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTypography.caption(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============ Status Chip ============
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSmall;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: (isSmall ? AppTypography.caption(context) : AppTypography.label(context)).copyWith(
          color: color,
          fontSize: isSmall ? 9 : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============ Priority Chip ============
class PriorityChip extends StatelessWidget {
  final String priority;
  final bool isSmall;

  const PriorityChip({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.priorityColor(priority);
    return StatusChip(
      label: priority,
      color: color,
      isSmall: isSmall,
    );
  }
}

// ============ Score Badge ============
class ScoreBadge extends StatelessWidget {
  final String score;

  const ScoreBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (score.toLowerCase()) {
      case 'hot':
        color = AppColors.danger;
        icon = Icons.local_fire_department;
        break;
      case 'warm':
        color = AppColors.warning;
        icon = Icons.thermostat;
        break;
      case 'cold':
        color = AppColors.info;
        icon = Icons.ac_unit;
        break;
      default:
        color = AppColors.textMuted;
        icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            score.toUpperCase(),
            style: AppTypography.caption(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Empty State ============
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 36,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppTypography.heading1(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.body(context),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

// ============ Info Card ============
class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodySmall(context)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTypography.heading2(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Section Header ============
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTypography.heading2(context)),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

// ============ Confirm Dialog ============
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  Color? confirmColor,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(        title: Text(title),
      content: Text(message, style: AppTypography.body(context)),
      // ignore: use_build_context_synchronously
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel, style: TextStyle(color: confirmColor ?? AppColors.danger)),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ============ Quick Action Button ============
class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 16),
          label: Text(label, style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(backgroundColor: color),
        ),
      ),
    );
  }
}
