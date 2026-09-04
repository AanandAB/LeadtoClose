import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../models/invoice.dart';
import '../../models/project.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);
    final invoices = ref.watch(invoicesProvider);
    final projects = ref.watch(projectsProvider);
    final clients = ref.watch(clientsProvider);

    // Revenue metrics
    final totalRevenue = invoices.where((i) => i.status == 'paid').fold(0.0, (s, i) => s + i.total);
    final outstanding = invoices.where((i) => i.status != 'paid' && i.status != 'cancelled').fold(0.0, (s, i) => s + i.balanceDue);
    final overdue = invoices.where((i) => i.isOverdue).fold(0.0, (s, i) => s + i.balanceDue);
    final avgInvoice = invoices.isNotEmpty ? totalRevenue / invoices.where((i) => i.status == 'paid').length : 0.0;

    // Pipeline metrics
    final totalLeads = leads.length;
    final wonLeads = leads.where((l) => l.stage == LeadStage.won).length;
    final lostLeads = leads.where((l) => l.stage == LeadStage.lost).length;
    final conversionRate = totalLeads > 0 ? (wonLeads / totalLeads * 100) : 0.0;

    // Project metrics
    final activeProjects = projects.where((p) => p.status == ProjectStatus.active).length;
    final completedProjects = projects.where((p) => p.status == ProjectStatus.completed).length;
    final overdueProjects = projects.where((p) => p.isOverdue).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports & Analytics', style: AppTypography.displayMedium(context)),
          const SizedBox(height: 24),

          // Revenue section
          _sectionHeader('Revenue Overview'),
          const SizedBox(height: 12),
          Row(
            children: [
              StatCard(label: 'Total Revenue', value: '\$${_fmt(totalRevenue)}', color: AppColors.success, icon: Icons.trending_up),
              const SizedBox(width: 16),
              StatCard(label: 'Outstanding', value: '\$${_fmt(outstanding)}', color: AppColors.warning, icon: Icons.schedule),
              const SizedBox(width: 16),
              StatCard(label: 'Overdue', value: '\$${_fmt(overdue)}', color: AppColors.danger, icon: Icons.warning_amber),
              const SizedBox(width: 16),
              StatCard(label: 'Avg Invoice', value: '\$${_fmt(avgInvoice)}', color: AppColors.info, icon: Icons.receipt),
            ],
          ),
          const SizedBox(height: 32),

          // Pipeline funnel
          _sectionHeader('Pipeline Conversion'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                _funnelBar('New Lead', leads.where((l) => l.stage == LeadStage.newLead).length, totalLeads, AppColors.stageNew),
                _funnelBar('Contacted', leads.where((l) => l.stage == LeadStage.contacted).length, totalLeads, AppColors.stageContacted),
                _funnelBar('Qualified', leads.where((l) => l.stage == LeadStage.qualified).length, totalLeads, AppColors.stageQualified),
                _funnelBar('Proposal Sent', leads.where((l) => l.stage == LeadStage.proposalSent).length, totalLeads, AppColors.stageProposal),
                _funnelBar('Negotiation', leads.where((l) => l.stage == LeadStage.negotiation).length, totalLeads, AppColors.stageNegotiation),
                _funnelBar('Won', wonLeads, totalLeads, AppColors.stageWon),
                _funnelBar('Lost', lostLeads, totalLeads, AppColors.stageLost),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Conversion Rate: ', style: AppTypography.body(context)),
                    Text('${conversionRate.toStringAsFixed(1)}%',
                        style: AppTypography.heading1(context).copyWith(
                          color: conversionRate > 20 ? AppColors.success : AppColors.warning,
                        )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Project status
          _sectionHeader('Project Status'),
          const SizedBox(height: 12),
          Row(
            children: [
              _projectStatusCard('Active', '$activeProjects', AppColors.info),
              const SizedBox(width: 16),
              _projectStatusCard('Completed', '$completedProjects', AppColors.success),
              const SizedBox(width: 16),
              _projectStatusCard('Overdue', '$overdueProjects', AppColors.danger),
              const SizedBox(width: 16),
              _projectStatusCard('Total', '${projects.length}', AppColors.primary),
            ],
          ),
          const SizedBox(height: 32),

          // Client overview
          _sectionHeader('Client Overview'),
          const SizedBox(height: 12),
          Row(
            children: [
              _clientOverviewCard('Total Clients', '${clients.length}', AppColors.info),
              const SizedBox(width: 16),
              _clientOverviewCard('Active', '${clients.where((c) => c.healthScore == 'active').length}', AppColors.success),
              const SizedBox(width: 16),
              _clientOverviewCard('At Risk', '${clients.where((c) => c.healthScore == 'at-risk').length}', AppColors.warning),
              const SizedBox(width: 16),
              _clientOverviewCard('Dormant', '${clients.where((c) => c.healthScore == 'dormant').length}', AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Builder(
      builder: (context) => Text(title, style: AppTypography.heading1(context)),
    );
  }

  Widget _funnelBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: AppTypography.body(context))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: AppColors.bgSurface,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(width: 40, child: Text('$count', style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _projectStatusCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.heading1(context).copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodySmall(context)),
          ],
        ),
      ),
    );
  }

  Widget _clientOverviewCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.heading1(context).copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.bodySmall(context)),
          ],
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}
