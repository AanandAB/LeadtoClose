
import '../models/project_profile.dart';
import '../models/compliance_item.dart';

class RulesEngine {
  static const Map<String, String> sacCodes = {
    'Brochure/Portfolio site': '998314',
    'E-commerce/Shop': '998314',
    'CRM/ERP/SaaS': '998314',
    'Custom Web App': '998314',
    'Mobile App': '998314',
    'Other': '998314',
  };

  static String getSacCode(String projectType) {
    return sacCodes[projectType] ?? '998314';
  }

  static List<ComplianceItem> evaluate(ProjectProfile profile) {
    final items = <ComplianceItem>[];
    int id = 0;

    // Always
    items.add(ComplianceItem(
      id: 'c${id++}', title: 'IP Assignment / License Clause',
      description: profile.wantsFullOwnership
          ? 'Full IP Assignment — client gets all rights upon full payment. Consider pricing premium.'
          : 'License Clause — freelancer retains core IP, client gets usage rights.',
      category: ComplianceCategory.contract,
    ));

    // Q2: Personal Data
    if (profile.collectsPersonalData) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'DPDPA Consent Flow + Privacy Notice',
        description: 'Build cookie consent banner, privacy policy page, and data collection notice per DPDPA 2023.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'DPDPA Data Handling Clause',
        description: 'Contract clause: Client acknowledged as Data Fiduciary, developer as Data Processor.',
        category: ComplianceCategory.contract,
      ));
    }

    // EU target
    if (profile.collectsPersonalData && profile.targetsEU) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'GDPR Cookie Consent + Data Portability',
        description: 'Implement GDPR-compliant cookie consent, privacy policy, and data portability mechanism.',
        category: ComplianceCategory.build,
      ));
    }

    // US/California target
    if (profile.collectsPersonalData && profile.targetsUS) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'CCPA Disclosures',
        description: 'CCPA-compliant privacy disclosures: data collection notice, opt-out mechanism.',
        category: ComplianceCategory.build,
      ));
    }

    // Q3: Payments
    if (profile.acceptsPayments) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'E-Commerce Consumer Protection Compliance',
        description: 'Grievance Officer block, return/refund/shipping policy pages per Consumer Protection E-Commerce Rules.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'E-Commerce Compliance Content Responsibility',
        description: 'Contract clause: Client acknowledges responsibility for ongoing e-commerce compliance content accuracy.',
        category: ComplianceCategory.contract,
      ));
    }

    // Q4: Physical goods
    if (profile.sellsPhysicalGoods) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'Legal Metrology Fields',
        description: 'Display MRP, net quantity, manufacturer, country of origin, and expiry on product pages.',
        category: ComplianceCategory.build,
      ));
    }

    // Q5: Client location
    if (profile.isInterState && !profile.isExport) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'GST Registration Mandatory (Inter-State)',
        description: 'Inter-state supply makes GST registration mandatory regardless of turnover. Register immediately if not already done.',
        category: ComplianceCategory.advisory,
      ));
    }

    if (profile.isExport) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'Export of Services — Zero-Rated GST + LUT',
        description: 'Export services are zero-rated with LUT. File LUT annually. Track FIRA/FIRC for each payment.',
        category: ComplianceCategory.advisory,
      ));
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'Export — Indian Jurisdiction Clause',
        description: 'Contract clause: Governing law — India, jurisdiction — freelancer local courts.',
        category: ComplianceCategory.contract,
      ));
    }

    // Q6: Hosting/Maintenance
    if (profile.requiresHosting) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'CERT-In 6-Hour Incident Reporting',
        description: 'Implement 6-hour incident reporting capability and 180-day security log retention per CERT-In directions.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'CERT-In Logging Setup',
        description: 'Configure 180-day logging for all security events as required by CERT-In.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'Data Processor Clause + SLA',
        description: 'Contract: Data Processor obligations (process only as instructed, security safeguards) + SLA with uptime/bug/feature definitions.',
        category: ComplianceCategory.contract,
      ));
    }

    // Q9: IP ownership
    if (profile.wantsFullOwnership) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'IP Assignment Premium',
        description: 'Full IP assignment — charge 30-50% premium. Transfer only on full payment.',
        category: ComplianceCategory.advisory,
      ));
    }

    // Q10: Children data
    if (profile.processesChildData) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'DPDPA Children Data Provisions',
        description: 'Verifiable parental consent required. No behavioral tracking or targeted advertising. Heightened data protection.',
        category: ComplianceCategory.build,
      ));
    }

    // Q1: SaaS
    if (profile.isSaas) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'SLA Required — Uptime + Support Definitions',
        description: 'Contract clause: SLA with uptime guarantee, bug vs feature definitions, support response times.',
        category: ComplianceCategory.contract,
      ));
    }

    // Q11: Retainer
    if (profile.isRetainer) {
      items.add(ComplianceItem(
        id: 'c${id++}', title: 'Recurring Invoice Template + SLA Renewal',
        description: 'Set up recurring invoice schedule and SLA auto-renewal reminders.',
        category: ComplianceCategory.invoicing,
      ));
    }

    return items;
  }

  // Rate card defaults for quote generation
  static Map<String, double> getDefaultRateCard(String projectTier) {
    double base;
    switch (projectTier) {
      case 'Basic (static/brochure)': base = 15000; break;
      case 'Standard (dynamic/CMS)': base = 45000; break;
      case 'Advanced (custom app/integrations)': base = 120000; break;
      case 'Enterprise (multi-module system)': base = 350000; break;
      default: base = 45000;
    }
    return {
      'Base Build': base,
      'DPDPA consent/privacy flow': 8000,
      'E-commerce compliance module': 12000,
      'Legal Metrology fields': 5000,
      'CERT-In logging + escalation setup': 10000,
      'Full IP Assignment premium': base * 0.4,
    };
  }

  static String getGstTreatment(ProjectProfile profile, bool isGstRegistered) {
    if (!isGstRegistered) return 'Not Registered';
    if (profile.isExport) return 'Zero-Rated (Export)';
    if (profile.isInterState) return 'IGST 18%';
    return 'CGST 9% + SGST 9%';
  }

  static double calculateGst(ProjectProfile profile, bool isGstRegistered, double subtotal) {
    if (!isGstRegistered || profile.isExport) return 0;
    return subtotal * 0.18;
  }
}
