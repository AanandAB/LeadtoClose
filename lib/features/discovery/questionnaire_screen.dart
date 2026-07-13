
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
  int _section = 0;
  int _questionInSection = 0;
  final Map<String, dynamic> _answers = {};
  final Map<String, List<String>> _multiAnswers = {};

  // ===== QUESTION DEFINITIONS =====
  // Each section has multiple questions. Sections: Type, Client, Data, Commerce, Hosting, IP, Legal

  static const _sections = [
    _Section('Project Type & Scope', Icons.code, [
      _Q('What are you building?', 'projectType', QType.single, [
        'Brochure/Portfolio site', 'E-commerce/Shop', 'CRM/ERP/SaaS',
        'Custom Web App', 'Mobile App', 'Other',
      ], help: 'The primary nature of the deliverable.'),
      _Q('Is this a website or a software platform?', 'projectCategory', QType.single, [
        'Website', 'Software Platform',
      ], help: 'Platforms (CRM, ERP, SaaS) carry different liability — see CERT-In and SLA obligations.'),
      _Q('What features will it include?', 'features', QType.multi, [
        'User login/accounts', 'Contact/reservation forms', 'Payment processing',
        'Product catalog', 'Dashboard/analytics', 'API integrations',
        'File uploads', 'Real-time chat/messaging', 'Email notifications',
      ], help: 'Select all that apply. This determines which laws are triggered.'),
      _Q('Expected project tier?', 'projectTier', QType.single, [
        'Basic (static/brochure)', 'Standard (dynamic/CMS)',
        'Advanced (custom app/integrations)', 'Enterprise (multi-module system)',
      ], help: 'Affects pricing, contract complexity, and whether source-code escrow is recommended.'),
    ]),

    _Section('Client Details', Icons.people, [
      _Q('Where is the client based?', 'clientLocation', QType.single, [
        'Same state as me', 'Different Indian state', 'Outside India',
      ], help: 'Determines GST treatment: intra-state, inter-state (mandatory GST), or export (zero-rated with LUT).'),
      _Q('Is the client a registered startup?', 'clientIsStartup', QType.single, [
        'Yes', 'No', 'Not sure',
      ], help: 'DPDPA Section 17(3) may exempt recognized startups from some compliance obligations.'),
      _Q('What industry is the client in?', 'clientIndustry', QType.single, [
        'Technology', 'E-commerce/Retail', 'Healthcare', 'Finance/Banking',
        'Education', 'Real Estate', 'Media/Entertainment', 'Other',
      ], help: 'Certain industries (healthcare, finance) trigger additional regulations.'),
    ]),

    _Section('Data & Privacy', Icons.privacy_tip, [
      _Q('Will it collect any personal data?', 'collectsPersonalData', QType.single, [
        'Yes', 'No',
      ], help: 'Names, emails, phone numbers, addresses — anything that can identify a person. Triggers DPDPA 2023.'),
      _Q('What kind of personal data?', 'dataTypes', QType.multi, [
        'Basic contact (name, email)', 'Location data', 'Financial/payment data',
        'Health/medical data', 'Biometric data', 'Government IDs',
      ], help: 'Financial and health data trigger stricter obligations under SPDI Rules 2011 and DPDPA.'),
      _Q('Will data of children (under 18) be processed?', 'processesChildData', QType.single, [
        'Yes', 'No', 'Unsure',
      ], help: 'Triggers DPDPA Section 9: verifiable parental consent, no behavioral tracking, penalty up to \u{20B9}200 crore.'),
      _Q('Where is the target audience?', 'targetAudience', QType.multi, [
        'India', 'EU', 'US/California', 'Other/Global',
      ], help: 'EU audience triggers GDPR (stricter than DPDPA). US/California triggers CCPA.'),
      _Q('Does it need regional language support?', 'needsRegionalLanguage', QType.single, [
        'Yes', 'No', 'Maybe',
      ], help: 'DPDPA Section 6(3): consent notice must be available in any of 22 scheduled Indian languages if user requests.'),
    ]),

    _Section('Commerce & Payments', Icons.payments, [
      _Q('Does it accept orders or payments?', 'paymentType', QType.single, [
        'Yes - online payment', 'Yes - COD/offline order', 'No',
      ], help: 'Triggers Consumer Protection E-Commerce Rules 2020 — even COD models.'),
      _Q('If selling, what type?', 'goodsType', QType.single, [
        'Physical goods', 'Digital goods', 'Service', 'N/A',
      ], help: 'Physical goods trigger Legal Metrology Rules (MRP, quantity, manufacturer fields required).'),
      _Q('Does the site use pre-ticked checkboxes?', 'hasPreCheckedBoxes', QType.single, [
        'Yes', 'No', 'Not sure',
      ], help: 'Pre-ticked boxes are explicitly prohibited by E-Commerce Rules. Consent must be explicit and affirmative.'),
    ]),

    _Section('Hosting & Maintenance', Icons.dns, [
      _Q('Who will host the site after completion?', 'hostingType', QType.single, [
        'No, handover only', 'I will host it', 'Client will host it', 'Third-party (AWS, etc.)',
      ], help: 'If you host or maintain, you become a Data Processor under DPDPA and trigger CERT-In obligations.'),
      _Q('Will you provide ongoing maintenance?', 'providesMaintenance', QType.single, [
        'Yes', 'No',
      ], help: 'Maintenance + hosting = CERT-In 6-hour incident reporting + 180-day logging requirement.'),
      _Q('Will you have access to the production server?', 'hasProductionAccess', QType.single, [
        'Yes', 'No',
      ], help: 'Production access means you may be treated as Data Processor even after handover.'),
    ]),

    _Section('IP & Assets', Icons.gavel, [
      _Q('Client\'s IP ownership expectation?', 'ipOwnership', QType.single, [
        'Wants full ownership', 'Open to licensing', 'Not yet discussed',
      ], help: 'Copyright Act default: you own the code even after payment. Assignment requires explicit written clause.'),
      _Q('Will you use third-party assets?', 'usesThirdPartyAssets', QType.single, [
        'Yes', 'No',
      ], help: 'Stock images, fonts, icons, code libraries — keep all license docs and hand to client.'),
      _Q('Will you reuse code/components from other projects?', 'willReuseCode', QType.single, [
        'Yes', 'No',
      ], help: 'If yes, a license (not assignment) protects your ability to reuse across clients.'),
      _Q('Could this be resold/white-labeled?', 'isResellable', QType.single, [
        'Yes', 'No', 'Maybe',
      ], help: 'If this is a platform you might resell, absolutely retain IP via license.'),
    ]),

    _Section('Legal & Contract', Icons.description, [
      _Q('Payment structure?', 'paymentTerms', QType.single, [
        '50% advance, 50% on delivery', '100% on delivery', 'Milestone-based',
        'Monthly retainer', 'Hourly',
      ], help: 'Affects contract payment terms and risk profile. Milestone structures reduce non-payment risk.'),
      _Q('Do you need a formal SLA?', 'needsSLA', QType.single, [
        'Yes', 'No', 'Not sure',
      ], help: 'SLA defines uptime, bug vs feature, and support response times. Recommended for hosted/maintained projects.'),
      _Q('Will you draft the Terms & Conditions?', 'developerDraftsTerms', QType.single, [
        'Yes', 'No — client provides them',
      ], help: 'Building the page structure is fine. Drafting actual legal terms as a developer exposes you — include a disclaimer.'),
      _Q('Estimated ongoing relationship?', 'ongoingRelationship', QType.single, [
        'One-time project', 'Retainer/ongoing', 'Unsure',
      ], help: 'Retainer clients need recurring invoice templates and SLA renewal reminders.'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    for (final section in _sections) {
      for (final q in section.questions) {
        if (q.type == QType.multi) {
          _multiAnswers[q.field] = [];
        } else {
          _answers[q.field] = null;
        }
      }
    }
  }

  int get _totalQuestions => _sections.fold(0, (sum, s) => sum + s.questions.length);
  int get _answeredSoFar {
    int count = 0;
    for (int s = 0; s < _sections.length; s++) {
      for (int q = 0; q < _sections[s].questions.length; q++) {
        if (s < _section || (s == _section && q < _questionInSection)) count++;
      }
    }
    // Count current question as answered if it has a value
    final currentQ = _sections[_section].questions[_questionInSection];
    if (currentQ.type == QType.multi) {
      if ((_multiAnswers[currentQ.field] ?? []).isNotEmpty) count++;
    } else {
      if (_answers[currentQ.field] != null) count++;
    }
    return count;
  }

  _Q get _currentQ => _sections[_section].questions[_questionInSection];
  bool get _isLastQuestion =>
      _section == _sections.length - 1 && _questionInSection == _sections[_section].questions.length - 1;

  void _next() {
    if (_questionInSection < _sections[_section].questions.length - 1) {
      setState(() => _questionInSection++);
    } else if (_section < _sections.length - 1) {
      setState(() { _section++; _questionInSection = 0; });
    }
  }

  void _prev() {
    if (_questionInSection > 0) {
      setState(() => _questionInSection--);
    } else if (_section > 0) {
      setState(() {
        _section--;
        _questionInSection = _sections[_section].questions.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final section = _sections[_section];
    final q = _currentQ;
    final progress = _answeredSoFar / _totalQuestions;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/lead/${widget.leadId}')),
        title: Text('Discovery', style: AppTypography.heading2(context)),
      ),
      body: Column(children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          color: AppColors.bgMid,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text('Section ${_section + 1} of ${_sections.length}', style: AppTypography.caption(context).copyWith(color: AppColors.primaryLight)),
              const Spacer(),
              Text('${_answeredSoFar}/${_totalQuestions}', style: AppTypography.caption(context)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress, minHeight: 4,
                backgroundColor: AppColors.borderLight,
              ),
            ),
            const SizedBox(height: 6),
            Row(children: [
              Icon(section.icon, size: 14, color: AppColors.primaryLight),
              const SizedBox(width: 6),
              Text(section.title, style: AppTypography.label(context).copyWith(color: AppColors.primaryLight)),
            ]),
          ]),
        ),

        // Question
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Question number + text
                Container(
                  width: 40, height: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('${_questionInSection + 1}', style: AppTypography.heading2(context).copyWith(color: AppColors.primaryLight)),
                  ),
                ),
                Text(q.question, style: AppTypography.heading1(context)),
                if (q.help != null) ...[
                  const SizedBox(height: 6),
                  Text(q.help!, style: AppTypography.body(context)),
                ],
                const SizedBox(height: 20),

                // Options
                if (q.type == QType.multi)
                  ...q.options.map((opt) => _checkboxTile(opt, q.field))
                else
                  ...q.options.map((opt) => _radioTile(opt, q.field)),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),

        // Navigation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgMid,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: SafeArea(
            child: Row(children: [
              if (_section > 0 || _questionInSection > 0)
                Expanded(
                  child: SizedBox(height: 48, child: OutlinedButton(
                    onPressed: _prev, child: const Text('Back'),
                  )),
                ),
              if (_section > 0 || _questionInSection > 0) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: SizedBox(height: 48, child: ElevatedButton(
                  onPressed: _hasAnswer ? (_isLastQuestion ? _submit : _next) : null,
                  child: Text(_isLastQuestion ? 'Complete Discovery' : 'Continue'),
                )),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  bool get _hasAnswer {
    final q = _currentQ;
    if (q.type == QType.multi) return (_multiAnswers[q.field] ?? []).isNotEmpty;
    return _answers[q.field] != null;
  }

  Widget _radioTile(String option, String field) {
    final selected = _answers[field] == option;
    return GestureDetector(
      onTap: () => setState(() => _answers[field] = option),
      child: Container(
        width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.primary : AppColors.textMuted, width: 2),
            ),
            child: selected ? Center(
              child: Container(width: 10, height: 10,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
            ) : null,
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(option, style: AppTypography.body(context).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ))),
          if (selected) const Icon(Icons.check, size: 18, color: AppColors.primary),
        ]),
      ),
    );
  }

  Widget _checkboxTile(String option, String field) {
    final selected = (_multiAnswers[field] ?? []).contains(option);
    return GestureDetector(
      onTap: () {
        setState(() {
          final list = _multiAnswers[field] ?? [];
          if (selected) { list.remove(option); } else { list.add(option); }
          _multiAnswers[field] = list;
        });
      },
      child: Container(
        width: double.infinity, margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
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
          Expanded(child: Text(option, style: AppTypography.body(context).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ))),
        ]),
      ),
    );
  }

  void _submit() {
    final profile = ProjectProfile(
      projectType: _str('projectType', 'Brochure/Portfolio site'),
      projectCategory: _str('projectCategory', 'Website'),
      features: List<String>.from(_multiAnswers['features'] ?? []),
      projectTier: _str('projectTier', 'Standard (dynamic/CMS)'),
      clientLocation: _str('clientLocation', 'Same state as me'),
      clientIsStartup: _str('clientIsStartup') == 'Yes',
      clientIndustry: _str('clientIndustry', 'Other'),
      collectsPersonalData: _str('collectsPersonalData') == 'Yes',
      dataTypes: List<String>.from(_multiAnswers['dataTypes'] ?? []),
      processesChildData: _str('processesChildData') == 'Yes',
      targetAudience: List<String>.from(_multiAnswers['targetAudience'] ?? []),
      needsRegionalLanguage: _str('needsRegionalLanguage') == 'Yes',
      paymentType: _str('paymentType', 'No'),
      goodsType: _str('goodsType', 'N/A'),
      hasPreCheckedBoxes: _str('hasPreCheckedBoxes') == 'Yes',
      hostingType: _str('hostingType', 'No, handover only'),
      providesMaintenance: _str('providesMaintenance') == 'Yes',
      hasProductionAccess: _str('hasProductionAccess') == 'Yes',
      ipOwnership: _str('ipOwnership', 'Not yet discussed'),
      usesThirdPartyAssets: _str('usesThirdPartyAssets') == 'Yes',
      willReuseCode: _str('willReuseCode') == 'Yes',
      isResellable: _str('isResellable') == 'Yes',
      paymentTerms: _str('paymentTerms', '50% advance, 50% on delivery'),
      needsSLA: _str('needsSLA') == 'Yes',
      developerDraftsTerms: _str('developerDraftsTerms') == 'Yes',
      ongoingRelationship: _str('ongoingRelationship', 'One-time project'),
    );

    final leads = ref.read(leadsProvider);
    final lead = leads.firstWhere((l) => l.id == widget.leadId);
    final updated = lead.copyWith(
      projectProfile: profile, stage: 'Discovery Done',
      lastActivity: DateTime.now(),
      notes: [...lead.notes, LeadNote(text: 'Discovery completed — ${_totalQuestions} questions across ${_sections.length} sections.', timestamp: DateTime.now())],
    );
    ref.read(leadsProvider.notifier).updateLead(updated);
    ref.read(currentProjectProfileProvider.notifier).state = profile;
    context.go('/lead/${widget.leadId}/compliance');
  }

  String _str(String field, [String defaultVal = '']) => _answers[field]?.toString() ?? defaultVal;
}

// ===== DATA TYPES =====
enum QType { single, multi }

class _Section {
  final String title;
  final IconData icon;
  final List<_Q> questions;
  const _Section(this.title, this.icon, this.questions);
}

class _Q {
  final String question;
  final String field;
  final QType type;
  final List<String> options;
  final String? help;
  const _Q(this.question, this.field, this.type, this.options, {this.help});
}
