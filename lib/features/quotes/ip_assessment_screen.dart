
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class IpAssessmentScreen extends ConsumerStatefulWidget {
  const IpAssessmentScreen({super.key});

  @override
  ConsumerState<IpAssessmentScreen> createState() => _IpAssessmentScreenState();
}

class _IpAssessmentScreenState extends ConsumerState<IpAssessmentScreen> {
  String? _clientWants;
  bool _willReuse = false;
  bool _isResellable = false;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        title: Text('IP Assessment', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: !_showResult ? _buildQuestions() : _buildResult(),
        ),
      ),
    );
  }

  Widget _buildQuestions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _introCard(),
      const SizedBox(height: 24),

      // Q1
      _questionLabel('What does the client want?'),
      const SizedBox(height: 8),
      _optionCard('Full ownership — they want everything', 'Wants full ownership',
          _clientWants == 'Wants full ownership', () => setState(() => _clientWants = 'Wants full ownership')),
      _optionCard('Right to use only — they just need the site/app to work', 'Open to licensing',
          _clientWants == 'Open to licensing', () => setState(() => _clientWants = 'Open to licensing')),
      _optionCard('Undecided — haven\'t discussed yet', 'Undecided',
          _clientWants == 'Undecided', () => setState(() => _clientWants = 'Undecided')),
      const SizedBox(height: 24),

      // Q2
      _questionLabel('Will you reuse any part of this code elsewhere?'),
      const SizedBox(height: 8),
      _switchRow('Yes — frameworks, components, utilities', _willReuse,
          (v) => setState(() => _willReuse = v)),
      const SizedBox(height: 24),

      // Q3
      _questionLabel('Is this a platform you might resell/white-label?'),
      const SizedBox(height: 8),
      _switchRow('Yes — reusable platform for multiple clients', _isResellable,
          (v) => setState(() => _isResellable = v)),
      const SizedBox(height: 32),

      SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: _clientWants != null ? () => setState(() => _showResult = true) : null,
          child: const Text('Get Recommendation'),
        ),
      ),
    ]);
  }

  Widget _buildResult() {
    final recommendation = _computeRecommendation();
    final isAssignment = recommendation['type'] == 'assignment';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Recommendation badge
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAssignment
                ? [AppColors.warning.withOpacity(0.2), AppColors.warning.withOpacity(0.05)]
                : [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAssignment ? AppColors.warning.withOpacity(0.3) : AppColors.success.withOpacity(0.3)),
        ),
        child: Column(children: [
          Icon(isAssignment ? Icons.assignment_turned_in : Icons.vpn_key,
              size: 48, color: isAssignment ? AppColors.warning : AppColors.success),
          const SizedBox(height: 12),
          Text(recommendation['label']!,
              style: AppTypography.heading1(context).copyWith(color: isAssignment ? AppColors.warning : AppColors.success)),
          const SizedBox(height: 4),
          Text(recommendation['summary']!, style: AppTypography.body(context), textAlign: TextAlign.center),
        ]),
      ),
      const SizedBox(height: 24),

      // Explanation
      _infoCard('What This Means', recommendation['explanation']!),
      const SizedBox(height: 12),

      // Pricing
      _infoCard('Pricing Recommendation', recommendation['pricing']!),

      const SizedBox(height: 24),

      // One-page explainer
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.visibility, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            Text('Client-Facing Explainer', style: AppTypography.label(context).copyWith(color: AppColors.primaryLight)),
          ]),
          const SizedBox(height: 12),
          Text(recommendation['explainer']!, style: AppTypography.body(context).copyWith(fontSize: 13)),
        ]),
      ),
      const SizedBox(height: 24),

      SizedBox(
        width: double.infinity, height: 48,
        child: OutlinedButton(
          onPressed: () => setState(() => _showResult = false),
          child: const Text('Re-assess'),
        ),
      ),
      const SizedBox(height: 40),
    ]);
  }

  Map<String, String> _computeRecommendation() {
    final wantsFull = _clientWants == 'Wants full ownership';

    if (_isResellable || (_willReuse && !wantsFull)) {
      return {
        'type': 'license',
        'label': 'Recommendation: LICENSE',
        'summary': 'Retain your IP — grant a usage license instead of transferring ownership.',
        'explanation': 'Since you either plan to reuse components or resell this as a platform, '
            'you should retain intellectual property rights. A license gives the client what they need '
            '(a working product) while protecting your ability to reuse your work.\n\n'
            'A license can be perpetual (they can use it forever) without transferring ownership. '
            'You retain the right to use the same frameworks, patterns, and components in other projects.',
        'pricing': 'No additional premium needed — the standard project price already reflects a license model. '
            'If the client insists on full ownership, charge a 40-50% IP buyout premium to compensate for '
            'the lost ability to reuse your work.',
        'explainer': 'When you hire a developer to build software, you\'re typically getting a license to use it — '
            'not ownership of the underlying code. Think of it like buying a house vs. renting:\n\n'
            'FULL ASSIGNMENT (buying): You own everything. You can modify, resell, or do whatever you want. Costs more.\n\n'
            'LICENSE (renting with full rights): You get full use of the product forever, but the developer '
            'keeps the right to reuse their tools and techniques for other clients. Costs less.\n\n'
            'For most websites and apps, a license is the standard arrangement — you get exactly what you need '
            '(a working, maintained product) without paying for ownership you don\'t need.',
      };
    } else if (wantsFull && !_willReuse && !_isResellable) {
      return {
        'type': 'assignment',
        'label': 'Recommendation: FULL ASSIGNMENT',
        'summary': 'Transfer full ownership — justified by the premium you\'ll charge.',
        'explanation': 'The client wants full ownership, and you don\'t plan to reuse any of this code. '
            'This is a clean case for full IP assignment — but charge for it.\n\n'
            'Full assignment means the client gets all rights upon full payment. You should still retain '
            'portfolio display rights and the right to reuse any pre-existing frameworks and libraries.',
        'pricing': 'Charge a 30-50% premium on your base rate for full IP assignment. '
            'Example: If the project is \u{20B9}1,00,000, add \u{20B9}30,000-\u{20B9}50,000 for full IP transfer. '
            'This compensates for the permanent loss of any reuse potential.',
        'explainer': 'FULL ASSIGNMENT means you\'re buying the complete rights to the software — '
            'source code, design, everything. Once paid, you own it outright.\n\n'
            'This costs more because the developer can never reuse any part of this work for another client. '
            'All the custom code, patterns, and solutions built for you are yours alone.\n\n'
            'Most clients don\'t actually need full assignment — a perpetual license gives you all the '
            'practical benefits (unlimited use, no recurring fees) at a lower cost. Full assignment is '
            'usually only needed if you plan to resell the software yourself.',
      };
    } else {
      return {
        'type': 'license',
        'label': 'Recommendation: LICENSE',
        'summary': 'Start with a license — you can always negotiate assignment later.',
        'explanation': 'Given your answers, a license is the more flexible starting point. '
            'It protects your IP by default while giving the client full usage rights.\n\n'
            'If the client later requests full ownership, you can negotiate it as a separate transaction '
            'with an appropriate premium.',
        'pricing': 'Standard project pricing applies. If assignment is requested later, '
            'quote a 30-50% premium as a separate line item.',
        'explainer': 'A LICENSE is the industry standard for custom software — you get unlimited use of '
            'your website or app, forever, with no hidden fees. The developer keeps the right to reuse '
            'their general tools and techniques, which is how they stay efficient and affordable.\n\n'
            'Practically speaking, you can do everything you need with a license: use the product, '
            'hire someone else to maintain it, make changes. The only thing you can\'t do is resell '
            'it as your own product — which most businesses don\'t need anyway.',
      };
    }
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.lightbulb, color: AppColors.primaryLight, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Answer 3 quick questions to get a recommendation on whether to assign '
              'or license your IP — plus a one-page explainer you can share with clients.',
              style: AppTypography.body(context)),
        ),
      ]),
    );
  }

  Widget _questionLabel(String text) {
    return Text(text, style: AppTypography.heading2(context).copyWith(fontSize: 16));
  }

  Widget _optionCard(String label, String value, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
          Expanded(child: Text(label, style: AppTypography.body(context).copyWith(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ))),
        ]),
      ),
    );
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: value ? AppColors.primary.withOpacity(0.05) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? AppColors.primary.withOpacity(0.2) : AppColors.borderLight.withOpacity(0.3)),
      ),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTypography.body(context))),
        Switch(
          value: value, onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ]),
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTypography.label(context).copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(body, style: AppTypography.body(context).copyWith(fontSize: 13)),
      ]),
    );
  }
}
