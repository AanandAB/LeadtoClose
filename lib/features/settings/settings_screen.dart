import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/app_settings.dart';
import '../../providers.dart';

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
  String _currency = 'USD';
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
    _taxRateCtrl = TextEditingController(text: settings.defaultTaxRate.toString());
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
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryTint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark Mode', style: AppTypography.body(context).copyWith(
                            color: AppColors.textPrimary, fontWeight: FontWeight.w600,
                          )),
                          Text(settings.isDarkMode ? 'Currently using dark theme' : 'Currently using light theme',
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
              _field('Business Name', _businessNameCtrl, Icons.business_outlined),
              const SizedBox(height: 12),
              _field('Your Name', _ownerNameCtrl, Icons.person_outline),
              const SizedBox(height: 12),
              _field('Email', _emailCtrl, Icons.email_outlined),
              const SizedBox(height: 12),
              _field('Phone', _phoneCtrl, Icons.phone_outlined),
              const SizedBox(height: 12),
              _field('Website', _websiteCtrl, Icons.language),
              const SizedBox(height: 12),
              _field('Address', _addressCtrl, Icons.location_on_outlined, maxLines: 2),
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
              _field('Tax Rate (%)', _taxRateCtrl, Icons.percent, isNumber: true),
              const SizedBox(height: 32),

              // Integrations
              _section('Integrations'),
              const SizedBox(height: 12),
              _integrationCard('Stripe', 'Accept payments via Stripe', Icons.payment, AppColors.primary, settings.integrations.contains('stripe')),
              _integrationCard('PayPal', 'Accept payments via PayPal', Icons.paypal, AppColors.info, settings.integrations.contains('paypal')),
              _integrationCard('Google Calendar', 'Sync events with Google Calendar', Icons.calendar_today, AppColors.success, settings.integrations.contains('google_calendar')),
              _integrationCard('Slack', 'Get notifications in Slack', Icons.notifications_active, AppColors.warning, settings.integrations.contains('slack')),
              _integrationCard('GitHub', 'Link repos to projects', Icons.code, AppColors.textSecondary, settings.integrations.contains('github')),
              const SizedBox(height: 32),

              // About
              _section('About'),
              const SizedBox(height: 12),
              _aboutRow('Version', '2.0.0 (Naro CRM)'),
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
      style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, bool isNumber = false}) {
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
        DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
        DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
        DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
        DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
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
        DropdownMenuItem(value: 'Due on Receipt', child: Text('Due on Receipt')),
        DropdownMenuItem(value: 'Net 15', child: Text('Net 15')),
        DropdownMenuItem(value: 'Net 30', child: Text('Net 30')),
        DropdownMenuItem(value: 'Net 45', child: Text('Net 45')),
        DropdownMenuItem(value: 'Net 60', child: Text('Net 60')),
      ],
      onChanged: (v) => setState(() => _paymentTerms = v!),
    );
  }

  Widget _integrationCard(String name, String desc, IconData icon, Color color, bool enabled) {
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
            width: 40, height: 40,
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
                Text(name, style: AppTypography.body(context).copyWith(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w600,
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
          SizedBox(width: 130, child: Text(label, style: AppTypography.bodySmall(context))),
          Expanded(child: Text(value, style: AppTypography.body(context))),
        ],
      ),
    );
  }

  void _saveSettings() {
    final current = ref.read(settingsProvider);
    ref.read(settingsProvider.notifier).save(
          current.copyWith(
            businessName: _businessNameCtrl.text.trim(),
            ownerName: _ownerNameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            website: _websiteCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            currency: _currency,
            defaultPaymentTerms: _paymentTerms,
            defaultTaxRate: double.tryParse(_taxRateCtrl.text) ?? 0,
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }
}
