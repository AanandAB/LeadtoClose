
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        title: Text('Settings', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _section(context, 'Business Profile'),
            const SizedBox(height: 12),
            if (profile != null) ...[
              _profileField(context, 'Business Name', profile.businessName),
              _profileField(context, 'Owner', profile.ownerName),
              _profileField(context, 'Structure', profile.businessStructure),
              _profileField(context, 'PAN', profile.pan),
              _profileField(context, 'GSTIN', profile.gstin.isNotEmpty ? profile.gstin : 'Not registered'),
              _profileField(context, 'Udyam/MSME', profile.udyamNumber.isNotEmpty ? profile.udyamNumber : 'Not registered'),
              _profileField(context, 'Home State', profile.homeState),
              _profileField(context, 'Email', profile.email),
              _profileField(context, 'Phone', profile.phone),
            ] else
              Text('No profile set up', style: AppTypography.body(context)),
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/onboarding'),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Business Profile'),
              ),
            ),
            const SizedBox(height: 32),

            _section(context, 'Rate Card'),
            const SizedBox(height: 12),
            Text('Configure your default pricing for project tiers and compliance add-ons.',
                style: AppTypography.body(context)),
            const SizedBox(height: 12),
            _rateCardItem(context, 'Basic (Static/Brochure)', '\u{20B9}15,000'),
            _rateCardItem(context, 'Standard (Dynamic/CMS)', '\u{20B9}45,000'),
            _rateCardItem(context, 'Advanced (Custom App)', '\u{20B9}1,20,000'),
            _rateCardItem(context, 'Enterprise (Multi-Module)', '\u{20B9}3,50,000'),
            _rateCardItem(context, 'DPDPA Compliance Add-on', '\u{20B9}8,000'),
            _rateCardItem(context, 'E-Commerce Module', '\u{20B9}12,000'),
            _rateCardItem(context, 'CERT-In Setup', '\u{20B9}10,000'),
            _rateCardItem(context, 'IP Assignment Premium', '40% of base'),
            const SizedBox(height: 32),

            _section(context, 'About'),
            const SizedBox(height: 12),
            _aboutRow(context, 'Version', '1.0.0 (MVP)'),
            _aboutRow(context, 'Platform', 'Flutter — Windows + Mobile + Web'),
            _aboutRow(context, 'Storage', 'Local (Hive) — data stays on your device'),
            _aboutRow(context, 'Compliance Engine', 'Rules v1 — DPDPA 2023, GST, CERT-In'),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity, height: 44,
              child: OutlinedButton.icon(
                onPressed: () => context.go('/rules-engine'),
                icon: const Icon(Icons.rule, size: 16),
                label: const Text('View Rules Engine — All 17 Rules'),
              ),
            ),
            const SizedBox(height: 8),
            Text('Disclaimer', style: AppTypography.label(context).copyWith(color: AppColors.warning)),
            const SizedBox(height: 4),
            Text('LeadToClose provides compliance checklists and draft documents based on stated project parameters. '
                'It is NOT a substitute for review by a qualified lawyer. Generated contracts should be reviewed '
                'before use, especially for enterprise-tier or first-of-kind engagements.',
                style: AppTypography.bodySmall(context)),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _section(BuildContext ctx, String title) {
    return Text(title, style: AppTypography.heading2(ctx).copyWith(color: AppColors.primaryLight));
  }

  Widget _profileField(BuildContext ctx, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: AppTypography.bodySmall(ctx))),
        Expanded(child: Text(value, style: AppTypography.body(ctx).copyWith(color: AppColors.textPrimary))),
      ]),
    );
  }

  Widget _rateCardItem(BuildContext ctx, String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: AppTypography.body(ctx))),
        Text(price, style: AppTypography.label(ctx).copyWith(color: AppColors.success)),
      ]),
    );
  }

  Widget _aboutRow(BuildContext ctx, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 130, child: Text(label, style: AppTypography.bodySmall(ctx))),
        Expanded(child: Text(value, style: AppTypography.body(ctx))),
      ]),
    );
  }
}
