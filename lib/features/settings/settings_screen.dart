import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/app_settings.dart';
import '../../models/lead.dart';
import '../../providers.dart';
import '../../services/lead_sync_service.dart';
import '../../services/portal_sync_service.dart';
import '../../widgets/app_snackbars.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _businessNameCtrl;
  late TextEditingController _ownerNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _taxRateCtrl;
  late TextEditingController _leadSyncUrlCtrl;
  late TextEditingController _leadSyncTokenCtrl;
  late TextEditingController _portalSyncUrlCtrl;
  late TextEditingController _portalSyncTokenCtrl;
  late TextEditingController _studioWhatsappCtrl;
  String _currency = AppCurrency.code;
  String _paymentTerms = 'Net 30';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _businessNameCtrl = TextEditingController(text: settings.businessName);
    _ownerNameCtrl = TextEditingController(text: settings.ownerName);
    _emailCtrl = TextEditingController(text: settings.email);
    _phoneCtrl = TextEditingController(text: settings.phone);
    _websiteCtrl = TextEditingController(text: settings.website);
    _addressCtrl = TextEditingController(text: settings.address);
    _taxRateCtrl =
        TextEditingController(text: settings.defaultTaxRate.toString());
    _leadSyncUrlCtrl = TextEditingController(text: settings.leadSyncUrl);
    _leadSyncTokenCtrl = TextEditingController(text: settings.leadSyncToken);
    _portalSyncUrlCtrl = TextEditingController(text: settings.portalSyncUrl);
    _portalSyncTokenCtrl =
        TextEditingController(text: settings.portalSyncToken);
    _studioWhatsappCtrl =
        TextEditingController(text: settings.studioWhatsappNumber);
    _currency = settings.currency;
    _paymentTerms = settings.defaultPaymentTerms;
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _websiteCtrl.dispose();
    _addressCtrl.dispose();
    _taxRateCtrl.dispose();
    _leadSyncUrlCtrl.dispose();
    _leadSyncTokenCtrl.dispose();
    _portalSyncUrlCtrl.dispose();
    _portalSyncTokenCtrl.dispose();
    _studioWhatsappCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Text('Settings', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance (at top for visibility)
              _section('Appearance'),
              const SizedBox(height: 12),

              // Dark Mode Toggle
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
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
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        settings.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark Mode',
                              style: AppTypography.body(context).copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              )),
                          Text(
                              settings.isDarkMode
                                  ? 'Currently using dark theme'
                                  : 'Currently using light theme',
                              style: AppTypography.bodySmall(context)),
                        ],
                      ),
                    ),
                    Switch(
                      value: settings.isDarkMode,
                      onChanged: (v) {
                        ref.read(settingsProvider.notifier).save(
                              settings.copyWith(isDarkMode: v),
                            );
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Branding
              _section('Branding'),
              const SizedBox(height: 12),
              _field(
                  'Business Name', _businessNameCtrl, Icons.business_outlined),
              const SizedBox(height: 12),
              _field('Your Name', _ownerNameCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _field('Email', _emailCtrl, Icons.email_outlined),
              const SizedBox(height: 12),
              _field('Phone', _phoneCtrl, Icons.phone_outlined),
              const SizedBox(height: 12),
              _field('Website', _websiteCtrl, Icons.language),
              const SizedBox(height: 12),
              _field('Address', _addressCtrl, Icons.location_on_outlined,
                  maxLines: 2),
              const SizedBox(height: 32),

              // Preferences
              _section('Preferences'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _currencyDropdown()),
                  const SizedBox(width: 16),
                  Expanded(child: _paymentTermsDropdown()),
                ],
              ),
              const SizedBox(height: 12),
              _field('Tax Rate (%)', _taxRateCtrl, Icons.percent,
                  isNumber: true),
              const SizedBox(height: 32),

              // Integrations
              _section('Integrations'),
              const SizedBox(height: 12),
              _integrationCard(
                  'Stripe',
                  'Accept payments via Stripe',
                  Icons.payment,
                  AppColors.primary,
                  settings.integrations.contains('stripe')),
              _integrationCard(
                  'PayPal',
                  'Accept payments via PayPal',
                  Icons.paypal,
                  AppColors.info,
                  settings.integrations.contains('paypal')),
              _integrationCard(
                  'Google Calendar',
                  'Sync events with Google Calendar',
                  Icons.calendar_today,
                  AppColors.success,
                  settings.integrations.contains('google_calendar')),
              _integrationCard(
                  'Slack',
                  'Get notifications in Slack',
                  Icons.notifications_active,
                  AppColors.warning,
                  settings.integrations.contains('slack')),
              _integrationCard(
                  'GitHub',
                  'Link repos to projects',
                  Icons.code,
                  AppColors.textSecondary,
                  settings.integrations.contains('github')),
              const SizedBox(height: 32),

              // Live Lead Sync (Cloudflare)
              _section('Live Lead Sync'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.cloud_sync_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Website → App live pipeline',
                                  style: AppTypography.body(context).copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                'Polls the Cloudflare lead worker and imports new website leads automatically.',
                                style: AppTypography.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings.leadSyncEnabled,
                          onChanged: (v) {
                            ref.read(settingsProvider.notifier).save(
                                  settings.copyWith(leadSyncEnabled: v),
                                );
                            if (v) {
                              _applySyncConfig(
                                  settings.copyWith(leadSyncEnabled: v));
                              showAppSnackbar(context, 'Live lead sync enabled',
                                  type: AppSnackbarType.success);
                            }
                          },
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _leadSyncUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Worker base URL',
                        hintText:
                            'https://bitnexel-leads.<account>.workers.dev',
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _leadSyncTokenCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Sync token (LEAD_SYNC_TOKEN)',
                        prefixIcon: Icon(Icons.key_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _studioWhatsappCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Studio WhatsApp number (digits only)',
                        prefixIcon: Icon(Icons.chat_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _saveAndTestSync,
                          icon: const Icon(Icons.sync_rounded, size: 18),
                          label: const Text('Save & Sync Now'),
                        ),
                        const SizedBox(width: 16),
                        Builder(builder: (context) {
                          final last = ref.watch(lastSyncProvider);
                          final error = ref.watch(syncErrorProvider);
                          return Expanded(
                            child: Text(
                              error ??
                                  (last != null
                                      ? 'Last sync: ${last.toLocal().toIso8601String().substring(0, 19)}'
                                      : 'Never synced'),
                              style: AppTypography.caption(context).copyWith(
                                color: error != null
                                    ? Colors.redAccent
                                    : AppColors.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Client Portal Sync (CRM -> portal)
              _section('Client Portal Sync'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
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
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.web_asset_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CRM -> Client portal push',
                                  style: AppTypography.body(context).copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                'Pushes your clients, projects and milestones to the Bitnexel client portal (D1).',
                                style: AppTypography.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settings.portalSyncEnabled,
                          onChanged: (v) {
                            ref.read(settingsProvider.notifier).save(
                                  settings.copyWith(portalSyncEnabled: v),
                                );
                            if (v) {
                              _applyPortalSyncConfig(
                                  settings.copyWith(portalSyncEnabled: v));
                            }
                          },
                          activeColor: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portalSyncUrlCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Portal API base URL',
                        hintText: 'https://api.bitnexel.in',
                        prefixIcon: Icon(Icons.link, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portalSyncTokenCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Sync token (PORTAL_SYNC_TOKEN)',
                        prefixIcon: Icon(Icons.key_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        FilledButton.icon(
                          onPressed: _saveAndTestPortalSync,
                          icon:
                              const Icon(Icons.cloud_upload_rounded, size: 18),
                          label: const Text('Save & Sync Now'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            ref.watch(portalSyncStatusProvider) ??
                                'Not synced yet',
                            style: AppTypography.caption(context).copyWith(
                              color: AppColors.textMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // About
              _section('About'),
              const SizedBox(height: 12),
              _aboutRow('Version', '2.0.0 (FreelanceHub)'),
              _aboutRow('Platform', 'Flutter — Cross-platform'),
              _aboutRow('Storage', 'Local (Hive) — data stays on your device'),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveSettings,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Settings'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Text(
      title,
      style: AppTypography.heading2(context)
          .copyWith(color: AppColors.primaryLight),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon,
      {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _currencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _currency,
      decoration: const InputDecoration(
        labelText: 'Currency',
        prefixIcon: Icon(Icons.monetization_on_outlined, size: 20),
      ),
      dropdownColor: AppColors.bgCard,
      items: const [
        DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
        DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
        DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
        DropdownMenuItem(value: 'AED', child: Text('AED (د.إ)')),
        DropdownMenuItem(value: 'SAR', child: Text('SAR (﷼)')),
        DropdownMenuItem(value: 'CAD', child: Text('CAD (\$)')),
        DropdownMenuItem(value: 'AUD', child: Text('AUD (\$)')),
      ],
      onChanged: (v) => setState(() => _currency = v!),
    );
  }

  Widget _paymentTermsDropdown() {
    return DropdownButtonFormField<String>(
      value: _paymentTerms,
      decoration: const InputDecoration(
        labelText: 'Payment Terms',
        prefixIcon: Icon(Icons.schedule, size: 20),
      ),
      dropdownColor: AppColors.bgCard,
      items: const [
        DropdownMenuItem(
            value: 'Due on Receipt', child: Text('Due on Receipt')),
        DropdownMenuItem(value: 'Net 15', child: Text('Net 15')),
        DropdownMenuItem(value: 'Net 30', child: Text('Net 30')),
        DropdownMenuItem(value: 'Net 45', child: Text('Net 45')),
        DropdownMenuItem(value: 'Net 60', child: Text('Net 60')),
      ],
      onChanged: (v) => setState(() => _paymentTerms = v!),
    );
  }

  Widget _integrationCard(
      String name, String desc, IconData icon, Color color, bool enabled) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
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
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTypography.body(context).copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    )),
                Text(desc, style: AppTypography.bodySmall(context)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (v) {
              final settings = ref.read(settingsProvider);
              final integrations = List<String>.from(settings.integrations);
              if (v) {
                integrations.add(name.toLowerCase().replaceAll(' ', '_'));
              } else {
                integrations.remove(name.toLowerCase().replaceAll(' ', '_'));
              }
              ref.read(settingsProvider.notifier).save(
                    settings.copyWith(integrations: integrations),
                  );
            },
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text(label, style: AppTypography.bodySmall(context))),
          Expanded(child: Text(value, style: AppTypography.body(context))),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final current = ref.read(settingsProvider);
    final updated = current.copyWith(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      currency: _currency,
      defaultPaymentTerms: _paymentTerms,
      defaultTaxRate: double.tryParse(_taxRateCtrl.text) ?? 0,
      leadSyncUrl: _leadSyncUrlCtrl.text.trim(),
      leadSyncToken: _leadSyncTokenCtrl.text.trim(),
      portalSyncUrl: _portalSyncUrlCtrl.text.trim(),
      portalSyncToken: _portalSyncTokenCtrl.text.trim(),
      studioWhatsappNumber: _studioWhatsappCtrl.text.trim(),
    );
    await ref.read(settingsProvider.notifier).save(updated);
    _applySyncConfig(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  void _applySyncConfig(AppSettings settings) {
    if (!settings.leadSyncEnabled || settings.leadSyncUrl.isEmpty) return;
    ref.read(leadSyncProvider).configure(LeadSyncConfig(
          baseUrl: settings.leadSyncUrl,
          token: settings.leadSyncToken,
        ));
  }

  Future<void> _saveAndTestSync() async {
    await _saveSettings();

    final url = _leadSyncUrlCtrl.text.trim();
    final token = _leadSyncTokenCtrl.text.trim();

    if (url.isEmpty || token.isEmpty) {
      if (mounted) {
        showAppSnackbar(context, 'Enter the lead worker URL & token first',
            type: AppSnackbarType.error);
      }
      return;
    }

    // Auto-enable live lead sync so it survives restart + the periodic timer.
    await ref
        .read(settingsProvider.notifier)
        .save(ref.read(settingsProvider).copyWith(leadSyncEnabled: true));

    ref.read(leadSyncProvider).configure(LeadSyncConfig(
          baseUrl: url,
          token: token,
        ));

    final imported = await ref.read(leadSyncProvider).pollNow();
    if (!mounted) return;
    if (imported > 0) {
      showAppSnackbar(context, '$imported new lead(s) imported',
          type: AppSnackbarType.success);
    } else {
      final error = ref.read(syncErrorProvider);
      showAppSnackbar(
        context,
        error ?? 'No new leads right now — pipeline healthy.',
        type: error != null ? AppSnackbarType.error : AppSnackbarType.info,
      );
    }
  }

  void _applyPortalSyncConfig(AppSettings settings) {
    if (!settings.portalSyncEnabled || settings.portalSyncUrl.isEmpty) return;
    final config = PortalSyncConfig(
      baseUrl: settings.portalSyncUrl,
      token: settings.portalSyncToken,
    );
    ref.read(portalSyncProvider).configure(config);
    ref.read(portalEventsProvider).configure(config);
  }

  Future<void> _saveAndTestPortalSync() async {
    await _saveSettings();

    final url = _portalSyncUrlCtrl.text.trim();
    final token = _portalSyncTokenCtrl.text.trim();

    if (url.isEmpty || token.isEmpty) {
      if (mounted) {
        ref.read(portalSyncStatusProvider.notifier).state =
            'Enter the portal URL & token first';
        showAppSnackbar(context, 'Enter the portal URL & token first',
            type: AppSnackbarType.error);
      }
      return;
    }

    // Auto-enable portal sync so it survives restart + the periodic timer.
    await ref
        .read(settingsProvider.notifier)
        .save(ref.read(settingsProvider).copyWith(portalSyncEnabled: true));

    final config = PortalSyncConfig(baseUrl: url, token: token);
    ref.read(portalSyncProvider).configure(config);
    ref.read(portalEventsProvider).configure(config);

    final result = await ref.read(portalSyncProvider).syncNow();
    await ref.read(portalEventsProvider).pullEvents();
    if (!mounted) return;
    if (result.ok) {
      ref.read(portalSyncStatusProvider.notifier).state =
          'Synced ${result.clients} clients · ${result.projects} projects · ${result.milestones} milestones';
      showAppSnackbar(
        context,
        'Portal synced: ${result.projects} project(s)',
        type: AppSnackbarType.success,
      );
    } else {
      ref.read(portalSyncStatusProvider.notifier).state =
          'Sync failed — check URL & token';
      showAppSnackbar(context, 'Portal sync failed — check URL & token',
          type: AppSnackbarType.error);
    }
  }
}
