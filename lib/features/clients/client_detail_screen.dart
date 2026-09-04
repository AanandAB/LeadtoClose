import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/client.dart';
import '../../models/project.dart';
import '../../models/invoice.dart';
import '../../models/communication.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  ConsumerState<ClientDetailScreen> createState() =>
      _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);
    final client = clients.where((c) => c.id == widget.clientId).firstOrNull;

    if (client == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
        ),
        body: const Center(child: Text('Client not found')),
      );
    }

    final projects = ref.watch(projectsProvider).where((p) => p.clientId == client.id).toList();
    final invoices = ref.watch(invoicesProvider).where((i) => i.clientId == client.id).toList();
    final communications = ref.watch(communicationsProvider).where((c) => c.clientId == client.id).toList();
    final quotes = ref.watch(quotesProvider).where((q) => q.clientId == client.id).toList();

    return Scaffold(
      body: Row(
        children: [
          // Left panel - Client info
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: AppColors.bgMid,
              border: Border(right: BorderSide(color: AppColors.borderLight)),
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Back button
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    Text('Clients', style: AppTypography.bodySmall(context)),
                  ],
                ),
                const SizedBox(height: 16),

                // Avatar & name
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.info.withOpacity(0.15),
                    child: Text(
                      client.companyName[0].toUpperCase(),
                      style: AppTypography.heading1(context).copyWith(
                        color: AppColors.infoLight,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    client.companyName,
                    style: AppTypography.heading1(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _healthColor(client.healthScore).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      client.healthScore.toUpperCase(),
                      style: AppTypography.caption(context).copyWith(
                        color: _healthColor(client.healthScore),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick stats
                Row(
                  children: [
                    _miniStat('Projects', '${projects.length}', AppColors.info),
                    _miniStat('Revenue', '\$${client.totalRevenue.toStringAsFixed(0)}', AppColors.success),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat('Invoices', '${invoices.length}', AppColors.warning),
                    _miniStat('Outstanding', '\$${client.outstandingBalance.toStringAsFixed(0)}', AppColors.danger),
                  ],
                ),
                const SizedBox(height: 24),

                // Contact info
                _infoSection('Contact', [
                  if (client.primaryContact != null) ...[
                    _infoRow(Icons.person_outline, client.primaryContact!.name),
                    if (client.primaryContact!.email.isNotEmpty)
                      _infoRow(Icons.email_outlined, client.primaryContact!.email),
                    if (client.primaryContact!.phone.isNotEmpty)
                      _infoRow(Icons.phone_outlined, client.primaryContact!.phone),
                  ],
                  if (client.industry.isNotEmpty)
                    _infoRow(Icons.category_outlined, client.industry),
                  if (client.website.isNotEmpty)
                    _infoRow(Icons.language, client.website),
                ]),
                const SizedBox(height: 16),

                _infoSection('Details', [
                  _infoRow(Icons.calendar_today, 'Since ${DateFormat('MMM yyyy').format(client.createdAt)}'),
                  if (client.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: client.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t, style: AppTypography.caption(context).copyWith(color: AppColors.primaryLight)),
                      )).toList(),
                    ),
                ]),
                const SizedBox(height: 24),

                // Actions
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Client'),
                  ),
                ),
              ],
            ),
          ),

          // Right panel - Content tabs
          Expanded(
            child: Column(
              children: [
                // Tab bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.bgMid,
                    border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      _tab('Overview', 0),
                      _tab('Projects', 1),
                      _tab('Invoices', 2),
                      _tab('Proposals', 3),
                      _tab('Messages', 4),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: _buildTabContent(client, projects, invoices, quotes, communications),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.body(context).copyWith(
            color: active ? AppColors.primaryLight : AppColors.textMuted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(Client client, List<Project> projects,
      List<Invoice> invoices, List<dynamic> quotes, List<Communication> comms) {
    switch (_activeTab) {
      case 0:
        return _buildOverviewTab(client, projects, invoices);
      case 1:
        return _buildProjectsTab(projects);
      case 2:
        return _buildInvoicesTab(invoices);
      case 3:
        return _buildProposalsTab(quotes);
      case 4:
        return _buildMessagesTab(comms);
      default:
        return _buildOverviewTab(client, projects, invoices);
    }
  }

  Widget _buildOverviewTab(Client client, List<Project> projects, List<Invoice> invoices) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent activity timeline
          Text('Activity Timeline', style: AppTypography.heading2(context)),
          const SizedBox(height: 16),
          if (projects.isEmpty && invoices.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No activity yet', style: AppTypography.bodySmall(context)),
              ),
            )
          else ...[
            // Show recent projects
            ...projects.take(3).map((p) => _timelineItem(
              Icons.folder_outlined,
              AppColors.info,
              'Project: ${p.name}',
              '${p.status.name} · Due ${p.dueDate != null ? DateFormat('MMM d').format(p.dueDate!) : 'TBD'}',
              p.createdAt,
            )),
            // Show recent invoices
            ...invoices.take(3).map((i) => _timelineItem(
              Icons.receipt_long,
              AppTheme.statusColor(i.status),
              'Invoice ${i.number}',
              '${i.status} · \$${i.total.toStringAsFixed(0)}',
              i.createdAt,
            )),
          ],

          const SizedBox(height: 32),
          // Financial summary
          Text('Financial Summary', style: AppTypography.heading2(context)),
          const SizedBox(height: 12),
          Row(
            children: [
              StatCard(
                label: 'Total Revenue',
                value: '\$${client.totalRevenue.toStringAsFixed(0)}',
                color: AppColors.success,
                icon: Icons.trending_up,
              ),
              const SizedBox(width: 16),
              StatCard(
                label: 'Outstanding',
                value: '\$${client.outstandingBalance.toStringAsFixed(0)}',
                color: AppColors.warning,
                icon: Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab(List<Project> projects) {
    if (projects.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.folder_outlined,
          title: 'No projects yet',
          subtitle: 'Create a project for this client',
          actionLabel: 'New Project',
          onAction: () {},
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
              if (p.budget > 0)
                Expanded(
                  child: Text('\$${p.budget.toStringAsFixed(0)}',
                      style: AppTypography.label(context)),
                ),
              if (p.dueDate != null)
                Expanded(
                  child: Text(DateFormat('MMM d').format(p.dueDate!),
                      style: AppTypography.bodySmall(context)),
                ),
              StatusChip(label: p.status.name, color: statusColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInvoicesTab(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'No invoices yet',
          subtitle: 'Create an invoice for this client',
          actionLabel: 'New Invoice',
          onAction: () {},
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, i) {
        final inv = invoices[i];
        final statusColor = AppTheme.statusColor(inv.status);
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
              Text(inv.number, style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              Text('\$${inv.total.toStringAsFixed(0)}',
                  style: AppTypography.price(context).copyWith(fontSize: 14)),
              const SizedBox(width: 12),
              StatusChip(label: inv.status, color: statusColor, isSmall: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProposalsTab(List<dynamic> quotes) {
    if (quotes.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.description_outlined,
          title: 'No proposals yet',
          subtitle: 'Send a proposal to this client',
          actionLabel: 'New Proposal',
          onAction: () {},
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, i) {
        final q = quotes[i];
        final statusColor = AppTheme.statusColor(q.status);
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
              Text(q.number, style: AppTypography.body(context).copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600,
              )),
              const Spacer(),
              Text('\$${q.total.toStringAsFixed(0)}',
                  style: AppTypography.price(context).copyWith(fontSize: 14)),
              const SizedBox(width: 12),
              StatusChip(label: q.status, color: statusColor, isSmall: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab(List<Communication> comms) {
    if (comms.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'No messages yet',
          subtitle: 'Start a conversation with this client',
          actionLabel: 'New Message',
          onAction: () {},
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: comms.length,
      itemBuilder: (context, i) {
        final c = comms[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Text(c.type.name.toUpperCase(),
                  style: AppTypography.caption(context).copyWith(
                    color: AppColors.info, fontWeight: FontWeight.w700,
                  )),
              const SizedBox(width: 12),
              Expanded(
                child: Text(c.subject.isNotEmpty ? c.subject : c.body,
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary,
                    ), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text(DateFormat('MMM d').format(c.createdAt),
                  style: AppTypography.caption(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _timelineItem(IconData icon, Color color, String title, String subtitle, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body(context).copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                )),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall(context)),
              ],
            ),
          ),
          Text(DateFormat('MMM d').format(date), style: AppTypography.caption(context)),
        ],
      ),
    );
  }

  Widget _infoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.label(context).copyWith(
          color: AppColors.textMuted, letterSpacing: 0.5,
        )),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: AppTypography.bodySmall(context),
            overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.heading3(context).copyWith(color: color)),
            const SizedBox(height: 2),
            Text(label, style: AppTypography.caption(context)),
          ],
        ),
      ),
    );
  }

  Color _healthColor(String health) {
    switch (health) {
      case 'active': return AppColors.success;
      case 'at-risk': return AppColors.warning;
      case 'dormant': return AppColors.textMuted;
      default: return AppColors.textMuted;
    }
  }
}
