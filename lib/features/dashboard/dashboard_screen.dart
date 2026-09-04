import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);
    final clients = ref.watch(clientsProvider);
    final projects = ref.watch(projectsProvider);
    final invoices = ref.watch(invoicesProvider);
    final quotes = ref.watch(quotesProvider);
    final events = ref.watch(eventsProvider);
    final settings = ref.watch(settingsProvider);

    final activeLeads = leads
        .where((l) =>
            l.stage != LeadStage.won && l.stage != LeadStage.lost)
        .length;
    final wonLeads = leads.where((l) => l.stage == LeadStage.won).length;
    final overdueLeads =
        leads.where((l) => l.followUpDate != null && l.isOverdue).length;

    final totalRevenue = invoices
        .where((i) => i.status == 'paid')
        .fold(0.0, (sum, i) => sum + i.total);
    final outstanding = invoices
        .where((i) => i.status != 'paid' && i.status != 'cancelled')
        .fold(0.0, (sum, i) => sum + i.balanceDue);
    final overdueAmount = invoices
        .where((i) => i.isOverdue)
        .fold(0.0, (sum, i) => sum + i.balanceDue);

    final activeProjects =
        projects.where((p) => p.status.name == 'active').length;
    final pendingQuotes = quotes.where((q) => q.status == 'sent').length;

    final upcomingEvents = events
        .where((e) => e.startTime.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final recentLeads = leads.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}',
                      style: AppTypography.body(context).copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.businessName.isNotEmpty
                          ? settings.businessName
                          : 'Dashboard',
                      style: AppTypography.displayLarge(context),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Online',
                      style: AppTypography.label(context).copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Revenue stats row
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Revenue',
                  value: '\$${_formatNumber(totalRevenue)}',
                  color: AppColors.revenue,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Outstanding',
                  value: '\$${_formatNumber(outstanding)}',
                  color: AppColors.warning,
                  icon: Icons.schedule_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Overdue',
                  value: '\$${_formatNumber(overdueAmount)}',
                  color: AppColors.danger,
                  icon: Icons.warning_amber_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Active Projects',
                  value: '$activeProjects',
                  color: AppColors.info,
                  icon: Icons.folder_open_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Secondary stats
          Row(
            children: [
              Expanded(
                child: _miniStat(
                  'Active Leads',
                  '$activeLeads',
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'Won Deals',
                  '$wonLeads',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'Pending Quotes',
                  '$pendingQuotes',
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _miniStat(
                  'Overdue Follow-ups',
                  '$overdueLeads',
                  AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Content grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Needs Attention
              Expanded(
                flex: 3,
                child: _buildNeedsAttention(
                    context, overdueLeads, overdueAmount, pendingQuotes),
              ),
              const SizedBox(width: 20),
              // Right column
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Upcoming Events
                    _buildUpcomingEvents(context, upcomingEvents),
                    const SizedBox(height: 16),
                    // Recent Leads
                    _buildRecentLeads(context, recentLeads),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.bodySmall(context)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.heading1(context).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsAttention(
    BuildContext context,
    int overdueLeads,
    double overdueAmount,
    int pendingQuotes,
  ) {
    final items = <_ActionItem>[];

    if (overdueAmount > 0) {
      items.add(_ActionItem(
        Icons.warning_amber_rounded,
        AppColors.danger,
        'Overdue Invoices',
        '\$${_formatNumber(overdueAmount)} needs attention',
      ));
    }

    if (overdueLeads > 0) {
      items.add(_ActionItem(
        Icons.schedule_rounded,
        AppColors.warning,
        'Missed Follow-ups',
        '$overdueLeads leads need follow-up',
      ));
    }

    if (pendingQuotes > 0) {
      items.add(_ActionItem(
        Icons.description_outlined,
        AppColors.info,
        'Pending Quotes',
        '$pendingQuotes quotes awaiting response',
      ));
    }

    if (items.isEmpty) {
      items.add(_ActionItem(
        Icons.check_circle_outline,
        AppColors.success,
        'All Clear',
        'No items need your attention',
      ));
    }

    return Container(
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
              Icon(Icons.notifications_outlined,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 8),
              Text('Needs Attention', style: AppTypography.heading2(context)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: item.color.withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20, color: item.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: AppTypography.bodySmall(context),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 18, color: item.color),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(
      BuildContext context, List<dynamic> upcomingEvents) {
    return Container(
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
              Icon(Icons.calendar_today_rounded,
                  size: 18, color: AppColors.info),
              const SizedBox(width: 8),
              Text('Upcoming', style: AppTypography.heading2(context)),
            ],
          ),
          const SizedBox(height: 16),
          if (upcomingEvents.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No upcoming events',
                  style: AppTypography.bodySmall(context),
                ),
              ),
            )
          else
            ...upcomingEvents.take(4).map((event) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, h:mm a')
                                  .format(event.startTime),
                              style: AppTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildRecentLeads(BuildContext context, List<Lead> recentLeads) {
    return Container(
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
              Icon(Icons.person_outline_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Recent Leads', style: AppTypography.heading2(context)),
            ],
          ),
          const SizedBox(height: 16),
          if (recentLeads.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No leads yet',
                  style: AppTypography.bodySmall(context),
                ),
              ),
            )
          else
            ...recentLeads.map((lead) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            AppColors.primary.withOpacity(0.15),
                        child: Text(
                          lead.name[0].toUpperCase(),
                          style: AppTypography.label(context).copyWith(
                            color: AppColors.primaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.name,
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              lead.company.isNotEmpty
                                  ? lead.company
                                  : lead.source,
                              style: AppTypography.caption(context),
                            ),
                          ],
                        ),
                      ),
                      StatusChip(
                        label: lead.stageLabel,
                        color: AppTheme.stageColor(lead.stageLabel),
                        isSmall: true,
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

class _ActionItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  const _ActionItem(this.icon, this.color, this.title, this.subtitle);
}
