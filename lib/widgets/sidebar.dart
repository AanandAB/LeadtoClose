import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSidebar extends ConsumerWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;

  const AppSidebar({
    super.key,
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        border: Border(
          right: BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          // Logo & brand (fixed at top)
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/freelancehub_logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'FreelanceHub',
                  style: AppTypography.heading2(context).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Scrollable navigation
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  _navSection(
                    context,
                    'OVERVIEW',
                    [_NavItem(0, Icons.dashboard_rounded, 'Dashboard')],
                  ),
                  const SizedBox(height: 16),
                  _navSection(
                    context,
                    'CRM',
                    [
                      _NavItem(1, Icons.view_kanban_rounded, 'Pipeline'),
                      _NavItem(2, Icons.people_outline_rounded, 'Clients'),
                      _NavItem(3, Icons.description_outlined, 'Proposals'),
                      _NavItem(4, Icons.gavel_outlined, 'Contracts'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _navSection(
                    context,
                    'WORK',
                    [
                      _NavItem(5, Icons.folder_outlined, 'Projects'),
                      _NavItem(6, Icons.timer_outlined, 'Time Tracking'),
                      _NavItem(7, Icons.receipt_long_outlined, 'Invoices'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _navSection(
                    context,
                    'TOOLS',
                    [
                      _NavItem(8, Icons.chat_bubble_outline_rounded, 'Messages'),
                      _NavItem(9, Icons.calendar_today_rounded, 'Calendar'),
                      _NavItem(10, Icons.folder_copy_outlined, 'Documents'),
                      _NavItem(11, Icons.analytics_outlined, 'Reports'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom section (pinned)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _navItemSmall(
                  context,
                  Icons.settings_rounded,
                  'Settings',
                  () => context.go('/settings'),
                ),
                const SizedBox(height: 8),
                if (settings.businessName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              settings.businessName[0].toUpperCase(),
                              style: AppTypography.label(context).copyWith(
                                color: AppColors.primaryLight,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            settings.businessName,
                            style: AppTypography.bodySmall(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _navSection(BuildContext context, String title, List<_NavItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: AppTypography.caption(context).copyWith(
              letterSpacing: 1.0,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildNavItem(context, item)),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item) {
    final active = currentTab == item.index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Material(
        color: active
            ? AppColors.primary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onTabChanged(item.index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: active
                      ? AppColors.primaryLight
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(
                  item.label,
                  style: AppTypography.body(context).copyWith(
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItemSmall(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(label, style: AppTypography.bodySmall(context)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

class _NavItem {
  final int index;
  final IconData icon;
  final String label;
  const _NavItem(this.index, this.icon, this.label);
}
