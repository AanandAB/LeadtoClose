
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../providers.dart';
import '../../services/storage_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final leads = ref.watch(leadsProvider);
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(context, profile),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [
                _buildPipeline(leads),
                _buildLeadsList(leads),
                _buildAnalytics(leads),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, profile) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.bgMid,
        border: Border(right: BorderSide(color: AppColors.borderLight.withOpacity(0.3))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_center, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Text('LeadToClose', style: AppTypography.heading2(context).copyWith(fontSize: 16)),
            ]),
          ),
          const SizedBox(height: 32),
          _navItem(Icons.view_kanban, 'Pipeline', 0),
          _navItem(Icons.list_alt, 'All Leads', 1),
          _navItem(Icons.analytics_outlined, 'Analytics', 2),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              if (profile != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, color: AppColors.primaryLight, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(profile.businessName, style: AppTypography.label(context), overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              const SizedBox(height: 8),
              _navItemSmall(Icons.gavel, 'IP Assessment', '/ip-assessment'),
              _navItemSmall(Icons.calendar_month, 'Tax Calendar', '/tax-calendar'),
              _navItemSmall(Icons.settings, 'Settings', '/settings'),
            ]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _currentTab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _currentTab = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(icon, size: 20, color: active ? AppColors.primaryLight : AppColors.textMuted),
              const SizedBox(width: 12),
              Text(label, style: AppTypography.body(context).copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              )),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItemSmall(IconData icon, String label, String route) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: () => context.go(route),
        icon: Icon(icon, size: 16),
        label: Text(label, style: AppTypography.bodySmall(context)),
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }

  // Pipeline Kanban
  Widget _buildPipeline(List<Lead> leads) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Pipeline', style: AppTypography.heading1(context)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.go('/lead/new'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Lead'),
          ),
        ]),
        const SizedBox(height: 20),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: StorageService.pipelineStages.map((stage) {
                final stageLeads = leads.where((l) => l.stage == stage).toList();
                return _buildPipelineColumn(stage, stageLeads, leads.length);
              }).toList(),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildPipelineColumn(String stage, List<Lead> leads, int totalLeads) {
    final isPositive = stage == 'Won';
    final isNegative = stage == 'Lost';

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16),
      child: Column(children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isPositive ? AppColors.success.withOpacity(0.1) :
                   isNegative ? AppColors.danger.withOpacity(0.1) :
                   AppColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: isPositive ? AppColors.success.withOpacity(0.3) :
                                        isNegative ? AppColors.danger.withOpacity(0.3) :
                                        AppColors.borderLight.withOpacity(0.3)),
          ),
          child: Row(children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPositive ? AppColors.success : isNegative ? AppColors.danger : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(stage, style: AppTypography.label(context).copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${leads.length}', style: AppTypography.caption(context)),
            ),
          ]),
        ),
        // Cards
        Container(
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withOpacity(0.5),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            border: Border(
              left: BorderSide(color: AppColors.borderLight.withOpacity(0.3)),
              right: BorderSide(color: AppColors.borderLight.withOpacity(0.3)),
              bottom: BorderSide(color: AppColors.borderLight.withOpacity(0.3)),
            ),
          ),
          child: Column(children: [
            if (leads.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No leads', style: AppTypography.bodySmall(context)),
              ),
            ...leads.map((lead) => _buildLeadCard(lead)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    return GestureDetector(
      onTap: () => context.go('/lead/${lead.id}'),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lead.name, style: AppTypography.label(context).copyWith(
            color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13,
          )),
          if (lead.company.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(lead.company, style: AppTypography.bodySmall(context)),
          ],
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.calendar_today, size: 10, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(DateFormat('dd MMM').format(lead.createdAt), style: AppTypography.caption(context)),
            const Spacer(),
            if (lead.projectProfile != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Discovered', style: AppTypography.caption(context).copyWith(
                  color: AppColors.success, fontSize: 9,
                )),
              ),
          ]),
        ]),
      ),
    );
  }

  // All Leads List
  Widget _buildLeadsList(List<Lead> leads) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('All Leads', style: AppTypography.heading1(context)),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => context.go('/lead/new'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Lead'),
          ),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: leads.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.inbox_outlined, size: 64, color: AppColors.textMuted.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No leads yet', style: AppTypography.heading2(context).copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Click "New Lead" to get started', style: AppTypography.body(context)),
                ]))
              : ListView.builder(
                  itemCount: leads.length,
                  itemBuilder: (context, i) {
                    final lead = leads[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.2),
                          child: Text(lead.name[0].toUpperCase(), style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
                        ),
                        title: Text(lead.name, style: AppTypography.body(context).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        subtitle: Text('${lead.stage} · ${lead.company}', style: AppTypography.bodySmall(context)),
                        trailing: _stageChip(lead.stage),
                        onTap: () => context.go('/lead/${lead.id}'),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // Analytics
  Widget _buildAnalytics(List<Lead> leads) {
    final won = leads.where((l) => l.stage == 'Won').length;
    final lost = leads.where((l) => l.stage == 'Lost').length;
    final active = leads.where((l) => l.stage != 'Won' && l.stage != 'Lost').length;
    final total = leads.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Analytics', style: AppTypography.heading1(context)),
        const SizedBox(height: 24),
        Row(children: [
          _statCard('Total Leads', '$total', AppColors.info),
          const SizedBox(width: 16),
          _statCard('Active', '$active', AppColors.primary),
          const SizedBox(width: 16),
          _statCard('Won', '$won', AppColors.success),
          const SizedBox(width: 16),
          _statCard('Lost', '$lost', AppColors.danger),
        ]),
        const SizedBox(height: 32),
        Text('Pipeline Breakdown', style: AppTypography.heading2(context)),
        const SizedBox(height: 12),
        ...StorageService.pipelineStages.map((stage) {
          final count = leads.where((l) => l.stage == stage).length;
          final pct = total > 0 ? count / total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              SizedBox(width: 120, child: Text(stage, style: AppTypography.body(context))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 8,
                    backgroundColor: AppColors.bgSurface,
                    valueColor: AlwaysStoppedAnimation(
                      stage == 'Won' ? AppColors.success :
                      stage == 'Lost' ? AppColors.danger :
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(width: 40, child: Text('$count', style: AppTypography.body(context).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
            ]),
          );
        }),
      ]),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTypography.displayLarge(context).copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.bodySmall(context)),
        ]),
      ),
    );
  }

  Widget _stageChip(String stage) {
    final isWon = stage == 'Won';
    final isLost = stage == 'Lost';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isWon ? AppColors.success.withOpacity(0.15) :
               isLost ? AppColors.danger.withOpacity(0.15) :
               AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(stage, style: AppTypography.caption(context).copyWith(
        color: isWon ? AppColors.success : isLost ? AppColors.danger : AppColors.primaryLight,
      )),
    );
  }
}
