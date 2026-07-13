
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/business_profile.dart';
import '../../providers.dart';

class BusinessProfileScreen extends ConsumerStatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  ConsumerState<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends ConsumerState<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _ownerCtrl, _panCtrl, _gstinCtrl, _udyamCtrl, _bankCtrl, _emailCtrl, _phoneCtrl;
  String _structure = 'Sole Proprietor';
  String _homeState = 'Kerala';

  static const _structures = ['Sole Proprietor', 'OPC', 'LLP'];
  static const _states = [
    'Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh','Goa','Gujarat',
    'Haryana','Himachal Pradesh','Jharkhand','Karnataka','Kerala','Madhya Pradesh',
    'Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Odisha','Punjab',
    'Rajasthan','Sikkim','Tamil Nadu','Telangana','Tripura','Uttar Pradesh',
    'Uttarakhand','West Bengal',
    'Andaman & Nicobar Islands','Chandigarh','Dadra & Nagar Haveli','Daman & Diu',
    'Delhi','Jammu & Kashmir','Ladakh','Lakshadweep','Puducherry',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(businessProfileProvider);
    _nameCtrl = TextEditingController(text: profile?.businessName ?? '');
    _ownerCtrl = TextEditingController(text: profile?.ownerName ?? '');
    _panCtrl = TextEditingController(text: profile?.pan ?? '');
    _gstinCtrl = TextEditingController(text: profile?.gstin ?? '');
    _udyamCtrl = TextEditingController(text: profile?.udyamNumber ?? '');
    _bankCtrl = TextEditingController(text: profile?.bankDetails ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    if (profile != null) {
      _structure = profile.businessStructure;
      _homeState = profile.homeState;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _ownerCtrl.dispose(); _panCtrl.dispose();
    _gstinCtrl.dispose(); _udyamCtrl.dispose(); _bankCtrl.dispose();
    _emailCtrl.dispose(); _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.rocket_launch_rounded, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('Welcome to LeadToClose', style: AppTypography.displayLarge(context)),
                    const SizedBox(height: 8),
                    Text('Set up your business profile once — everything else flows from here.', style: AppTypography.body(context)),
                    const SizedBox(height: 40),
                    _sectionHeader('Business Details'),
                    const SizedBox(height: 16),
                    _buildTextField('Business Name *', _nameCtrl, Icons.business),
                    const SizedBox(height: 14),
                    _buildTextField('Your Name *', _ownerCtrl, Icons.person),
                    const SizedBox(height: 14),
                    _buildDropdown('Business Structure', _structure, _structures, (v) => setState(() => _structure = v!)),
                    const SizedBox(height: 14),
                    _buildTextField('PAN *', _panCtrl, Icons.credit_card, uppercase: true),
                    const SizedBox(height: 14),
                    _buildTextField('GSTIN (if registered)', _gstinCtrl, Icons.receipt_long, uppercase: true),
                    const SizedBox(height: 14),
                    _buildTextField('Udyam/MSME Number (if registered)', _udyamCtrl, Icons.verified_user),
                    const SizedBox(height: 30),
                    _sectionHeader('Contact & Banking'),
                    const SizedBox(height: 16),
                    _buildTextField('Email', _emailCtrl, Icons.email),
                    const SizedBox(height: 14),
                    _buildTextField('Phone', _phoneCtrl, Icons.phone),
                    const SizedBox(height: 14),
                    _buildDropdown('Home State', _homeState, _states, (v) => setState(() => _homeState = v!)),
                    const SizedBox(height: 14),
                    _buildTextField('Bank Details', _bankCtrl, Icons.account_balance, maxLines: 2),
                    const SizedBox(height: 14),
                    _buildTextField('Late Fee % (for contracts)', TextEditingController(text: '18'), Icons.percent, enabled: false),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save & Continue'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (ref.read(businessProfileProvider) != null)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => context.go('/dashboard'),
                          child: const Text('Skip for now'),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final profile = BusinessProfile(
      businessName: _nameCtrl.text.trim(),
      ownerName: _ownerCtrl.text.trim(),
      businessStructure: _structure,
      pan: _panCtrl.text.trim(),
      gstin: _gstinCtrl.text.trim(),
      udyamNumber: _udyamCtrl.text.trim(),
      homeState: _homeState,
      bankDetails: _bankCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    ref.read(businessProfileProvider.notifier).save(profile);
    context.go('/dashboard');
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight));
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1, bool uppercase = false, bool enabled = true}) {
    return TextFormField(
      controller: ctrl,
      enabled: enabled,
      maxLines: maxLines,
      textCapitalization: uppercase ? TextCapitalization.characters : TextCapitalization.words,
      style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
      validator: label.contains('*') ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.list, size: 20)),
      dropdownColor: AppColors.bgSurface,
      style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
      items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: onChanged,
    );
  }
}
