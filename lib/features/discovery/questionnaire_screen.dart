
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../models/project_profile.dart';
import '../../models/lead.dart';
import '../../providers.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  final String leadId;
  const QuestionnaireScreen({super.key, required this.leadId});

  @override
  ConsumerState<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final Map<String, dynamic> _answers = {};

  static const _projectTypes = ['Brochure/Portfolio site', 'E-commerce/Shop', 'CRM/ERP/SaaS', 'Custom Web App', 'Mobile App', 'Other'];
  static const _yesNo = ['Yes', 'No'];
  static const _paymentTypes = ['Yes - online payment', 'Yes - COD/offline order', 'No'];
  static const _goodsTypes = ['Physical goods', 'Digital goods', 'Service', 'N/A'];
  static const _clientLocations = ['Same state as me', 'Different Indian state', 'Outside India'];
  static const _hostingTypes = ['Yes - hosting only', 'Yes - hosting + ongoing maintenance', 'No, handover only'];
  static const _audience = ['India', 'EU', 'US/California', 'Other/Global'];
  static const _tiers = ['Basic (static/brochure)', 'Standard (dynamic/CMS)', 'Advanced (custom app/integrations)', 'Enterprise (multi-module system)'];
  static const _ipOptions = ['Wants full ownership', 'Open to licensing', 'Not yet discussed'];
  static const _childOptions = ['Yes', 'No', 'Unsure'];
  static const _relationshipOptions = ['One-time project', 'Retainer/ongoing', 'Unsure'];

  List<_Question> get _questions => [
    _Question('What are you building?', _projectTypes, 'projectType', Icons.code),
    _Question('Will it collect personal data?', _yesNo, 'collectsPersonalData', Icons.privacy_tip),
    _Question('Does it accept orders or payments?', _paymentTypes, 'paymentType', Icons.payments),
    _Question('If selling, what type?', _goodsTypes, 'goodsType', Icons.inventory_2),
    _Question('Where is the client based?', _clientLocations, 'clientLocation', Icons.location_on),
    _Question('Will you host/maintain after handover?', _hostingTypes, 'hostingType', Icons.dns),
    _Question('Target audience? (multi-select)', _audience, 'targetAudience', Icons.public),
    _Question('Expected project tier?', _tiers, 'projectTier', Icons.trending_up),
    _Question('Client IP ownership expectation?', _ipOptions, 'ipOwnership', Icons.gavel),
    _Question('Will child data (under 18) be processed?', _childOptions, 'processesChildData', Icons.child_care),
    _Question('Estimated ongoing relationship?', _relationshipOptions, 'ongoingRelationship', Icons.repeat),
  ];

  @override
  void initState() {
    super.initState();
    for (final q in _questions) {
      if (q.field == 'targetAudience') {
        _answers[q.field] = <String>[];
      } else {
        _answers[q.field] = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Discovery', style: AppTypography.heading2(context)),
      ),
      body: Form(
        key: _formKey,
        child: Column(children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: [
              for (int i = 0; i < _questions.length; i++)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: i <= _currentStep ? AppColors.primary : AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text('Question ${_currentStep + 1} of ${_questions.length}',
                style: AppTypography.bodySmall(context)),
          ),

          // Question
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _buildQuestion(_questions[_currentStep]),
                ),
              ),
            ),
          ),

          // Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(children: [
              if (_currentStep > 0)
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _currentStep < _questions.length - 1 ? () => setState(() => _currentStep++) : _submit,
                    child: Text(_currentStep < _questions.length - 1 ? 'Next' : 'Complete Discovery'),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildQuestion(_Question q) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(q.icon, size: 28, color: AppColors.primaryLight),
      ),
      const SizedBox(height: 24),
      Text(q.question, style: AppTypography.heading1(context)),
      const SizedBox(height: 6),
      Text('Select one option', style: AppTypography.body(context)),
      const SizedBox(height: 24),
      if (q.field == 'targetAudience')
        ..._audience.map((a) => _buildCheckboxTile(a))
      else
        ...q.options.map((option) => _buildRadioTile(option, q.field)),
    ]);
  }

  Widget _buildRadioTile(String option, String field) {
    final selected = _answers[field] == option;
    return GestureDetector(
      onTap: () => setState(() => _answers[field] = option),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight.withOpacity(0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.primary : AppColors.textMuted, width: 2),
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(option, style: AppTypography.body(context).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ))),
        ]),
      ),
    );
  }

  Widget _buildCheckboxTile(String option) {
    final selected = (_answers['targetAudience'] as List).contains(option);
    return GestureDetector(
      onTap: () {
        setState(() {
          final list = _answers['targetAudience'] as List<String>;
          if (selected) { list.remove(option); } else { list.add(option); }
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight.withOpacity(0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: selected ? AppColors.primary : AppColors.textMuted, width: 2),
              color: selected ? AppColors.primary : Colors.transparent,
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
          const SizedBox(width: 14),
          Text(option, style: AppTypography.body(context).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          )),
        ]),
      ),
    );
  }

  void _submit() {
    final profile = ProjectProfile(
      projectType: _answers['projectType'] ?? _projectTypes[0],
      collectsPersonalData: _answers['collectsPersonalData'] == 'Yes',
      paymentType: _answers['paymentType'] ?? 'No',
      goodsType: _answers['goodsType'] ?? 'N/A',
      clientLocation: _answers['clientLocation'] ?? _clientLocations[0],
      hostingType: _answers['hostingType'] ?? _hostingTypes[2],
      targetAudience: List<String>.from(_answers['targetAudience'] ?? []),
      projectTier: _answers['projectTier'] ?? _tiers[1],
      ipOwnership: _answers['ipOwnership'] ?? _ipOptions[2],
      processesChildData: _answers['processesChildData'] == 'Yes',
      ongoingRelationship: _answers['ongoingRelationship'] ?? _relationshipOptions[0],
    );

    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final updated = lead.copyWith(
      projectProfile: profile,
      stage: 'Discovery Done',
      lastActivity: DateTime.now(),
      notes: [...lead.notes, LeadNote(text: 'Discovery questionnaire completed.', timestamp: DateTime.now())],
    );
    ref.read(leadsProvider.notifier).updateLead(updated);
    ref.read(currentProjectProfileProvider.notifier).state = profile;
    context.go('/lead/${widget.leadId}/compliance');
  }
}

class _Question {
  final String question;
  final List<String> options;
  final String field;
  final IconData icon;
  const _Question(this.question, this.options, this.field, this.icon);
}
