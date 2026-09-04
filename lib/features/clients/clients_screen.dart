import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/client.dart';
import '../../providers.dart';
import '../../widgets/shared_widgets.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  ConsumerState<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  String _searchQuery = '';
  String _healthFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final clients = ref.watch(clientsProvider);
    final filtered = clients.where((c) {
      final matchesSearch = c.companyName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          c.contacts.any((ct) =>
              ct.name.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesHealth =
          _healthFilter == 'all' || c.healthScore == _healthFilter;
      return matchesSearch && matchesHealth;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Clients', style: AppTypography.displayMedium(context)),
              const Spacer(),
              StatusChip(
                label: '${clients.length} clients',
                color: AppColors.info,
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showAddClientDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Client'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search & filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search clients...',
                    prefixIcon:
                        const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _filterChip('All', 'all'),
              _filterChip('Active', 'active'),
              _filterChip('At Risk', 'at-risk'),
              _filterChip('Dormant', 'dormant'),
            ],
          ),
          const SizedBox(height: 16),

          // Clients list
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Icons.people_outline_rounded,
                    title: 'No clients yet',
                    subtitle:
                        'Add your first client to get started',
                    actionLabel: 'Add Client',
                    onAction: () => _showAddClientDialog(context),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, i) =>
                        _buildClientCard(context, filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _healthFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: () => setState(() => _healthFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.label(context).copyWith(
              color: selected
                  ? AppColors.primaryLight
                  : AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, Client client) {
    final healthColor = client.healthScore == 'active'
        ? AppColors.success
        : client.healthScore == 'at-risk'
            ? AppColors.warning
            : AppColors.textMuted;

    return GestureDetector(
      onTap: () => context.go('/client/${client.id}'),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.info.withOpacity(0.15),
            child: Text(
              client.companyName[0].toUpperCase(),
              style: AppTypography.heading2(context).copyWith(
                color: AppColors.infoLight,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.companyName,
                  style: AppTypography.body(context).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (client.primaryContact != null)
                  Text(
                    '${client.primaryContact!.name} · ${client.primaryContact!.email}',
                    style: AppTypography.bodySmall(context),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: healthColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  client.healthScore.toUpperCase(),
                  style: AppTypography.caption(context).copyWith(
                    color: healthColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
              if (client.totalRevenue > 0) ...[
                const SizedBox(height: 4),
                Text(
                  AppCurrency.format(client.totalRevenue),
                  style: AppTypography.label(context).copyWith(
                    color: AppColors.revenue,
                  ),
                ),
              ],
            ],
          ),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
            onSelected: (v) => _handleClientAction(v, client),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ],
      ),
    ),
    );
  }

  void _handleClientAction(String action, Client client) {
    if (action == 'edit') {
      context.go('/client/${client.id}');
      return;
    }
    if (action == 'delete') {
      ref.read(clientsProvider.notifier).deleteClient(client.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Client deleted'),
            action: SnackBarAction(label: 'Undo', onPressed: () {
              ref.read(clientsProvider.notifier).addClient(client);
            }),
          ),
        );
      }
    }
  }

  void _showAddClientDialog(BuildContext context) {
    final companyCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String industry = 'Technology';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add New Client', style: AppTypography.heading2(context)),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: companyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    prefixIcon: Icon(Icons.business_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Primary Contact Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: industry,
                  decoration: const InputDecoration(
                    labelText: 'Industry',
                    prefixIcon: Icon(Icons.category_outlined, size: 20),
                  ),
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(
                        value: 'Technology', child: Text('Technology')),
                    DropdownMenuItem(
                        value: 'E-commerce', child: Text('E-commerce')),
                    DropdownMenuItem(
                        value: 'Healthcare', child: Text('Healthcare')),
                    DropdownMenuItem(
                        value: 'Finance', child: Text('Finance')),
                    DropdownMenuItem(
                        value: 'Education', child: Text('Education')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (v) => industry = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (companyCtrl.text.trim().isEmpty) return;
              final client = Client(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                companyName: companyCtrl.text.trim(),
                contacts: nameCtrl.text.trim().isNotEmpty
                    ? [
                        Contact(
                          id: '1',
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          isPrimary: true,
                        ),
                      ]
                    : [],
                industry: industry,
              );
              ref.read(clientsProvider.notifier).addClient(client);
              Navigator.pop(ctx);
            },
            child: const Text('Add Client'),
          ),
        ],
      ),
    );
  }
}
