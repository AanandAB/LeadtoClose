
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/lead.dart';
import '../../providers.dart';

class LeadFormScreen extends ConsumerStatefulWidget {
  const LeadFormScreen({super.key});

  @override
  ConsumerState<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends ConsumerState<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _companyCtrl, _contactCtrl, _notesCtrl;
  String _source = 'Direct';
  String _stage = 'New Lead';

  static const _sources = ['Direct', 'Referral', 'Upwork', 'LinkedIn', 'Website', 'Other'];
  static const _stages = ['New Lead', 'Qualified'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _contactCtrl = TextEditingController();
    _notesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _companyCtrl.dispose();
    _contactCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('New Lead', style: AppTypography.heading2(context)),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _sectionHeader('Lead Information'),
                const SizedBox(height: 16),
                _buildTextField('Client Name *', _nameCtrl, Icons.person),
                const SizedBox(height: 14),
                _buildTextField('Company', _companyCtrl, Icons.business),
                const SizedBox(height: 14),
                _buildTextField('Contact (phone/email)', _contactCtrl, Icons.contact_mail),
                const SizedBox(height: 14),
                _buildDropdown('Source', _source, _sources, (v) => setState(() => _source = v!)),
                const SizedBox(height: 14),
                _buildDropdown('Initial Stage', _stage, _stages, (v) => setState(() => _stage = v!)),
                const SizedBox(height: 20),
                _sectionHeader('Initial Notes'),
                const SizedBox(height: 12),
                _buildTextField('Notes (optional)', _notesCtrl, Icons.notes, maxLines: 3),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _saveLead,
                    child: const Text('Create Lead'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Cancel'),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  void _saveLead() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final lead = Lead(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      contact: _contactCtrl.text.trim(),
      source: _source,
      stage: _stage,
      createdAt: now,
      notes: _notesCtrl.text.trim().isNotEmpty
          ? [LeadNote(text: _notesCtrl.text.trim(), timestamp: now)]
          : [],
    );
    ref.read(leadsProvider.notifier).addLead(lead);
    context.go('/lead/${lead.id}');
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight));
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl, maxLines: maxLines,
      style: AppTypography.body(context).copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, size: 20)),
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
