import '../models/project_profile.dart';
import '../models/compliance_item.dart';

class RulesEngine {
  static const Map<String, String> sacCodes = {
    'Brochure/Portfolio site': '998364',
    'E-commerce/Shop': '998314',
    'CRM/ERP/SaaS': '998314',
    'Custom Web App': '998314',
    'Mobile App': '998314',
    'Other': '998314',
  };

  static String getSacCode(String projectType) => sacCodes[projectType] ?? '998314';

  static List<ComplianceItem> evaluate(ProjectProfile p) {
    final items = <ComplianceItem>[];
    int id = 0;

    // ========== ALWAYS ==========
    items.add(ComplianceItem(id: 'c${id++}',
      title: 'Written Contract Required',
      description: 'Every project needs a signed written contract. WhatsApp/email agreements are technically enforceable under the IT Act, but a signed contract is far stronger in a dispute.',
      category: ComplianceCategory.contract,
    ));

    items.add(ComplianceItem(id: 'c${id++}',
      title: p.wantsFullOwnership ? 'IP Assignment Clause (Full Ownership)' : 'IP License Clause',
      description: p.wantsFullOwnership
          ? 'Full IP Assignment — client gets all rights upon full payment. Per Copyright Act Section 19, specify: work assigned, rights transferred, duration (forever, worldwide — or it defaults to 5 years India-only), and territory. Charge 30-50% premium.'
          : 'License Clause — freelancer retains core IP, client gets usage rights. Copyright Act default: you own the code even after payment unless explicitly assigned.',
      category: ComplianceCategory.contract,
    ));

    items.add(ComplianceItem(id: 'c${id++}',
      title: 'UAT / Sign-Off Document',
      description: 'Get written handover/User Acceptance Testing approval. This closes scope and prevents "free tweaks" later.',
      category: ComplianceCategory.contract,
    ));

    // ========== SECTION 2: CLIENT DETAILS ==========
    if (p.clientIsStartup) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'DPDPA Startup Exemption Check (Section 17(3))',
        description: 'Your client may qualify for reduced DPDPA obligations if they\'re a recognized startup. Flag this — their lawyer should check if this exemption has been activated by government notification.',
        category: ComplianceCategory.advisory,
      ));
    }

    if (p.isExport) {
      items.add(ComplianceItem(id: 'c${id++}', 
        title: 'Export of Services — Zero-Rated GST + LUT',
        description: 'Export services are zero-rated with a valid LUT (Letter of Undertaking). File LUT annually on the GST portal. Without it: 18% IGST upfront, refund later — cash-flow problem.',
        category: ComplianceCategory.advisory,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Indian Jurisdiction Clause',
        description: 'Contract must state: governing law — India, exclusive jurisdiction — your local courts. Prevents being pulled into foreign litigation.',
        category: ComplianceCategory.contract,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'FIRA/FIRC Tracking Required',
        description: 'Every foreign payment must generate a FIRA/e-FIRA (Foreign Inward Remittance Advice). Save for 6 years per FEMA. Needed for both tax filing and FEMA compliance.',
        category: ComplianceCategory.invoicing,
      ));
    }

    if (p.isInterState) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'GST Registration Mandatory (Inter-State Client)',
        description: 'Inter-state supply makes GST registration mandatory from the first rupee — regardless of turnover. This is the rule most freelancers miss.',
        category: ComplianceCategory.advisory,
      ));
    }

    // ========== SECTION 3: DATA & PRIVACY ==========
    if (p.collectsPersonalData) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'DPDPA Consent Mechanism',
        description: 'Build a consent flow with: notice of data collected + purpose, clear affirmative action (no pre-ticked boxes), and withdrawal as easy as giving consent.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Privacy Notice / Policy Page',
        description: 'Per DPDPA Section 5: must state what data is collected, for what purpose, how to withdraw consent, and how to complain to the Data Protection Board.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Data Fiduciary/Processor Role Definition',
        description: 'Contract must state who is Data Fiduciary (usually the client) and who is Data Processor (you, if hosting/maintaining). Per DPDPA Section 8(2): processor must be under valid contract.',
        category: ComplianceCategory.contract,
      ));
    }

    if (p.collectsFinancialData) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Financial Data — Heightened Security',
        description: 'Collecting financial/payment data triggers stricter security obligations under DPDPA and SPDI Rules 2011. PCI-DSS compliance may apply.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.collectsHealthData) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Health Data — Sensitive Personal Data',
        description: 'Health/medical data is classified as sensitive under SPDI Rules 2011. Requires explicit consent, purpose limitation, and heightened security standards.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.processesChildData) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'DPDPA Children\'s Data (Section 9)',
        description: 'Verifiable parental/guardian consent required before processing under-18 data. No behavioral monitoring or targeted advertising directed at children. Penalty: up to ₹200 crore.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.collectsPersonalData && p.targetsEU) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'GDPR Compliance — Cookie Consent + Data Portability',
        description: 'EU audience triggers GDPR: cookie consent banner, data portability, right to erasure, and DPO appointment for large-scale processing. GDPR is stricter than DPDPA.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.collectsPersonalData && p.targetsUS) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'CCPA Disclosures',
        description: 'US/California audience triggers CCPA: data collection notice, opt-out mechanism for data selling, and privacy rights disclosures.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.needsRegionalLanguage) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'DPDPA Regional Language Support (Section 6(3))',
        description: 'Per DPDPA: consent notice must be available in English or any of the 22 scheduled Indian languages if the user requests. Build CMS fields for multi-language content.',
        category: ComplianceCategory.build,
      ));
    }

    // ========== SECTION 4: COMMERCE & PAYMENTS ==========
    if (p.acceptsPayments) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Consumer Protection E-Commerce Rules Compliance',
        description: 'Must display: legal name, address, customer care, named Grievance Officer. Grievance Officer must acknowledge complaints in 48 hours, resolve in 30 days.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Return/Refund/Cancellation/Shipping Policies',
        description: 'E-Commerce Rules require clear return, refund, cancellation, and shipping policies displayed on the site — even for COD models.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'E-Commerce Content Responsibility Clause',
        description: 'Contract clause: client acknowledges responsibility for ongoing accuracy of e-commerce content (product descriptions, pricing, policies).',
        category: ComplianceCategory.contract,
      ));
    }

    if (p.hasPreCheckedBoxes) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Remove Pre-Ticked Checkboxes — Illegal Under E-Commerce Rules',
        description: 'Consumer Protection E-Commerce Rules explicitly prohibit pre-ticked checkboxes. Consent must be explicit and affirmative. Remove immediately.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.sellsPhysicalGoods) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Legal Metrology — Product Label Fields',
        description: 'Per Legal Metrology (Packaged Commodities) Rules: display MRP, net quantity, manufacturer name, country of origin, and expiry on product pages. Build these as mandatory CMS fields.',
        category: ComplianceCategory.build,
      ));
    }

    // ========== SECTION 5: HOSTING & MAINTENANCE ==========
    if (p.isHostingAndMaintaining) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'CERT-In 6-Hour Incident Reporting',
        description: 'Per CERT-In Directions (28 April 2022): report qualifying cyber incidents within 6 hours of becoming aware. Implement centralized logging, NTP sync, and documented incident response.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'CERT-In 180-Day Log Retention',
        description: 'Maintain ICT system logs for a rolling 180 days, stored within Indian jurisdiction. Must be handed to CERT-In on request. Non-compliance: up to 1 year imprisonment.',
        category: ComplianceCategory.build,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Data Processor Contract Required',
        description: 'If you host/maintain the system with user data, you\'re the Data Processor. DPDPA Section 8(2): this must be under a valid contract specifying security safeguards and processing instructions.',
        category: ComplianceCategory.contract,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Indemnity for DPDPA Penalties',
        description: 'DPDPA penalties (up to ₹250 crore) fall on the Data Fiduciary (client), but your contract\'s indemnity clause determines if negligence-based penalties pass to you. Negotiate explicitly.',
        category: ComplianceCategory.contract,
      ));
    }

    if (p.requiresHosting && !p.providesMaintenance) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Limitation of Liability — Post-Handover',
        description: 'Include clause: you\'re not liable for breaches, plugin failures, or issues from client-side changes after handover. But if you have ongoing server access, CERT-In obligations persist.',
        category: ComplianceCategory.contract,
      ));
    }

    // ========== SECTION 6: IP & ASSETS ==========
    if (p.usesThirdPartyAssets) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Third-Party IP Clearance — License Documentation',
        description: 'If using stock images, fonts, icons, or code libraries: keep all license docs and hand to client. Using unlicensed assets exposes you to indemnity claims.',
        category: ComplianceCategory.build,
      ));
    }

    if (p.wantsFullOwnership) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'IP Assignment Premium (30-50%)',
        description: 'Full IP assignment costs 30-50% more than license. Compensates for permanent loss of reuse rights. Assignment must specify duration (forever, worldwide — or it defaults to 5 years India-only per Copyright Act).',
        category: ComplianceCategory.advisory,
      ));
    }

    if (p.willReuseCode) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Code Reuse — License Recommended',
        description: 'Since you plan to reuse code/components, a license (not full assignment) protects your ability to reuse across clients. If client insists on assignment, charge a premium.',
        category: ComplianceCategory.advisory,
      ));
    }

    if (p.isResellable) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Resellable Platform — Retain IP',
        description: 'If this is a platform you might resell/white-label, absolutely retain IP via license. Full assignment would foreclose future revenue.',
        category: ComplianceCategory.advisory,
      ));
    }

    if (p.projectTier == 'Advanced' || p.projectTier == 'Enterprise') {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Source Code Escrow Consideration',
        description: 'For high-value projects, consider offering source code escrow — protects client if you disappear mid-project. Adds credibility for enterprise clients.',
        category: ComplianceCategory.advisory,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Version Control + Client Access',
        description: 'Use GitHub/GitLab with client access for version history. Protects both parties in scope disputes.',
        category: ComplianceCategory.build,
      ));
    }

    // ========== SECTION 7: LEGAL & CONTRACT ==========
    if (p.developerDraftsTerms) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Terms & Conditions — Client Must Vet',
        description: 'You can build the page structure, but legal content should come from the client or their lawyer. Drafting legal terms as a developer exposes you if they\'re inadequate. Include a disclaimer.',
        category: ComplianceCategory.advisory,
      ));
    }

    if (p.needsSLA || p.isSaaS) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'SLA Required — Define Bug vs Feature',
        description: 'SLA must define: (a) "bug" (free fix during warranty) vs "feature" (billable), (b) uptime guarantee (e.g., 99.5%), (c) response times for critical vs non-critical tickets.',
        category: ComplianceCategory.contract,
      ));
    }

    if (p.isSaaS) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Software License Agreement (Not Assignment)',
        description: 'For CRM/ERP/SaaS: use a Software License Agreement. You retain core IP, client gets usage rights. Full assignment only at significant premium.',
        category: ComplianceCategory.contract,
      ));
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Data Export + Transition on Termination',
        description: 'Define what happens on contract termination: data export format, transition assistance period, and any post-termination support obligations.',
        category: ComplianceCategory.contract,
      ));
    }

    if (p.isRetainer) {
      items.add(ComplianceItem(id: 'c${id++}',
        title: 'Recurring Invoice Template + Auto-Renewal',
        description: 'Set up recurring invoice schedule and SLA auto-renewal reminders. Consider quarterly invoicing for retainer clients.',
        category: ComplianceCategory.invoicing,
      ));
    }

    // ========== ALWAYS (END) ==========
    items.add(ComplianceItem(id: 'c${id++}',
      title: 'Electronic Execution Clause (IT Act Section 10-A)',
      description: 'Include clause: electronic signatures and communications (email, WhatsApp) are valid and binding. This removes ambiguity about whether informal approvals count.',
      category: ComplianceCategory.contract,
    ));

    items.add(ComplianceItem(id: 'c${id++}',
      title: 'Universal Handover Disclaimer',
      description: 'In handover email: "This software has been built with standard compliance features based on agreed scope. I provide development services, not legal counsel. Client remains responsible for final content, policies, and ongoing compliance. Have policy text reviewed by a qualified lawyer before go-live."',
      category: ComplianceCategory.advisory,
    ));

    items.add(ComplianceItem(id: 'c${id++}',
      title: 'Payment Protection — Deliver on Full Payment',
      description: 'Deliver watermarked/low-res previews and withhold source files/repo access until final payment clears. Legally defensible under Copyright Act default ownership.',
      category: ComplianceCategory.advisory,
    ));

    items.add(ComplianceItem(id: 'c${id++}',
      title: 'Back Up All Client Communication',
      description: 'Screenshot and back up all WhatsApp/email approvals and scope discussions. IT Act recognizes these as admissible evidence. Essential if a dispute arises.',
      category: ComplianceCategory.advisory,
    ));

    return items;
  }

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
      'GDPR compliance add-on': 15000,
      'CCPA compliance add-on': 10000,
      'Legal Metrology fields': 5000,
      'CERT-In logging + escalation setup': 10000,
      'Full IP Assignment premium': base * 0.4,
      'Multi-language consent (per language)': 3000,
      'SLA drafting': 8000,
    };
  }

  static String getGstTreatment(ProjectProfile p, bool isGstRegistered) {
    if (!isGstRegistered) return 'Not Registered';
    if (p.isExport) return 'Zero-Rated (Export)';
    if (p.isInterState) return 'IGST 18%';
    return 'CGST 9% + SGST 9%';
  }

  static double calculateGst(ProjectProfile p, bool isGstRegistered, double subtotal) {
    if (!isGstRegistered || p.isExport) return 0;
    return subtotal * 0.18;
  }
}
