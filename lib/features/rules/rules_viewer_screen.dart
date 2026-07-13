
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class RulesViewerScreen extends ConsumerWidget {
  const RulesViewerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/dashboard')),
        title: Text('Compliance Rules Engine', style: AppTypography.heading2(context)),
      ),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppColors.primaryLight, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(
                'Rules Engine v1.0 — DPDPA 2023, GST, CERT-In. Every rule maps a discovery answer to a compliance action. '
                'When Indian law changes (GST thresholds, DPDPA rule dates), update the rule set here — no code change needed.',
                style: AppTypography.body(context).copyWith(fontSize: 12),
              )),
            ]),
          ),
          const SizedBox(height: 24),

          ..._rules.map((rule) => _ruleCard(context, rule)),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  Widget _ruleCard(BuildContext context, _Rule rule) {
    final catColor = rule.category == 'Build' ? AppColors.info :
                     rule.category == 'Contract' ? AppColors.warning :
                     rule.category == 'Advisory' ? AppColors.primaryLight :
                     AppColors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(), collapsedShape: const Border(),
        leading: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(_catIcon(rule.category), size: 16, color: catColor),
        ),
        title: Text(rule.title, style: AppTypography.body(context).copyWith(
          fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13,
        )),
        subtitle: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
            child: Text(rule.category, style: AppTypography.caption(context).copyWith(color: catColor, fontSize: 9)),
          ),
          const SizedBox(width: 8),
          Text(rule.trigger, style: AppTypography.caption(context).copyWith(fontSize: 9)),
        ]),
        children: [
          Text(rule.description, style: AppTypography.body(context).copyWith(fontSize: 12)),
          if (rule.contractClause != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Contract Clause:', style: AppTypography.caption(context).copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(rule.contractClause!, style: AppTypography.body(context).copyWith(fontSize: 11, fontStyle: FontStyle.italic)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Build': return Icons.build;
      case 'Contract': return Icons.description;
      case 'Advisory': return Icons.lightbulb;
      case 'Invoicing': return Icons.receipt_long;
      default: return Icons.help;
    }
  }
}

class _Rule {
  final String title;
  final String trigger;
  final String description;
  final String category;
  final String? contractClause;
  const _Rule(this.title, this.trigger, this.description, this.category, {this.contractClause});
}

const _rules = [
  _Rule('IP Assignment/License Clause', 'Always', 'Every project requires either an IP assignment (full ownership transfer on payment) or license (freelancer retains core IP).', 'Contract',
      contractClause: 'Upon receipt of full payment, the Developer assigns all rights OR grants perpetual license per project profile.'),
  _Rule('DPDPA Consent Flow + Privacy Notice', 'Q2 = Yes (collects personal data)', 'Build cookie consent banner, privacy policy page, and data collection notice per DPDPA 2023. Required for any website/app collecting user data.', 'Build'),
  _Rule('DPDPA Data Handling Clause', 'Q2 = Yes', 'Contract clause: Client is Data Fiduciary, Developer is Data Processor — process only as instructed with security safeguards.', 'Contract',
      contractClause: 'Client is Data Fiduciary under DPDPA 2023. Developer processes data only on documented instructions with reasonable security safeguards.'),
  _Rule('GDPR Cookie Consent + Data Portability', 'Q2 = Yes AND Q7 includes EU', 'GDPR-compliant cookie consent banner, privacy policy, and data portability/right-to-erasure mechanisms for EU users.', 'Build'),
  _Rule('CCPA Disclosures', 'Q2 = Yes AND Q7 includes US/California', 'CCPA-compliant privacy disclosures with data collection notice and opt-out mechanism for California residents.', 'Build'),
  _Rule('E-Commerce Consumer Protection Compliance', 'Q3 accepts payments', 'Grievance Officer contact block, return/refund policy, and shipping policy pages per Consumer Protection E-Commerce Rules 2020.', 'Build'),
  _Rule('E-Commerce Content Responsibility Clause', 'Q3 accepts payments', 'Contract clause: Client acknowledges responsibility for ongoing e-commerce compliance content accuracy.', 'Contract',
      contractClause: 'Client is responsible for accuracy of product descriptions, pricing, return/refund policies, and Grievance Officer contact details.'),
  _Rule('Legal Metrology Fields', 'Q4 = Physical goods', 'Display MRP, net quantity, manufacturer name, country of origin, and expiry date on all product pages.', 'Build'),
  _Rule('GST Registration Mandatory (Inter-State)', 'Q5 = Different Indian state', 'Inter-state supply makes GST registration mandatory regardless of turnover — flag to freelancer immediately.', 'Advisory'),
  _Rule('Export Services — Zero-Rated GST + LUT', 'Q5 = Outside India', 'Export of services is zero-rated with LUT. File LUT annually. Track FIRA/FIRC for every foreign payment.', 'Advisory'),
  _Rule('Export Jurisdiction Clause', 'Q5 = Outside India', 'Contract clause: Governing law — India, jurisdiction — freelancer\'s local courts.', 'Contract',
      contractClause: 'This Agreement governed by Indian law. Exclusive jurisdiction: courts at [Freelancer Location], India.'),
  _Rule('CERT-In 6-Hour Incident Reporting', 'Q6 includes hosting', 'Implement 6-hour cybersecurity incident reporting capability and maintain 180-day security logs per CERT-In directions.', 'Build'),
  _Rule('Data Processor Clause + SLA', 'Q6 includes hosting', 'Contract: Data Processor obligations + SLA defining uptime, bug vs feature, and support response times.', 'Contract',
      contractClause: 'Developer acts as Data Processor. SLA: 99.5% uptime, 24-hour bug response, 72-hour feature request response.'),
  _Rule('IP Assignment Premium (30-50%)', 'Q9 = Wants full ownership', 'Full IP assignment costs 30-50% more — compensates for permanent loss of reuse rights.', 'Advisory'),
  _Rule('DPDPA Children Data Provisions', 'Q10 = Yes/Unsure (child data)', 'Verifiable parental consent required. No behavioral tracking or targeted advertising toward children.', 'Build'),
  _Rule('SLA Required for SaaS', 'Q1 = CRM/ERP/SaaS', 'Contract must include SLA: uptime guarantee, bug vs feature definitions, support response times.', 'Contract',
      contractClause: 'SLA: 99.5% uptime, Tier 1 (critical bug) 4h response, Tier 2 (feature) 72h response.'),
  _Rule('Recurring Invoice Template', 'Q11 = Retainer/ongoing', 'Set up recurring monthly/quarterly invoice schedule with auto-reminders.', 'Invoicing'),
];
