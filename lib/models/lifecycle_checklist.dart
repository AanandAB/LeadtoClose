/// Lifecycle checklists — three separate templates (Website / Custom Software /
/// Web App) covering the complete Bitnexel delivery lifecycle, including DPDP
/// Act 2023 compliance and security hardening gates.
///
/// A [ChecklistInstance] is created from a template (e.g. when a lead is won
/// or a project starts) and persists per-project in Hive, so progress is
/// live-synced across app restarts and devices via the Cloudflare pipeline.
library;

/// The three Bitnexel disciplines — each gets its own checklist track.
enum ChecklistTrack { website, software, webapp }

extension ChecklistTrackX on ChecklistTrack {
  String get label {
    switch (this) {
      case ChecklistTrack.website:
        return 'Website';
      case ChecklistTrack.software:
        return 'Custom Software';
      case ChecklistTrack.webapp:
        return 'Web App / SaaS';
    }
  }

  String get description {
    switch (this) {
      case ChecklistTrack.website:
        return 'Digital flagship & marketing sites — performance, SEO and brand experience.';
      case ChecklistTrack.software:
        return 'Custom software & ERPs — process automation, integrations and data integrity.';
      case ChecklistTrack.webapp:
        return 'Cloud web apps & SaaS — multi-tenancy, scale, billing and uptime.';
    }
  }

  static ChecklistTrack fromName(String? name) =>
      ChecklistTrack.values.firstWhere(
        (t) => t.name == name,
        orElse: () => ChecklistTrack.website,
      );
}

/// Bitnexel delivery lifecycle phases, shared across all three tracks.
enum LifecyclePhase {
  discovery,
  proposal,
  agreement,
  design,
  development,
  qaSecurity,
  launch,
  handover,
  support,
}

extension LifecyclePhaseX on LifecyclePhase {
  String get label {
    switch (this) {
      case LifecyclePhase.discovery:
        return '1. Discovery & Requirements';
      case LifecyclePhase.proposal:
        return '2. Proposal & Estimation';
      case LifecyclePhase.agreement:
        return '3. Agreement & Compliance Baseline';
      case LifecyclePhase.design:
        return '4. Design & Prototyping';
      case LifecyclePhase.development:
        return '5. Development';
      case LifecyclePhase.qaSecurity:
        return '6. QA & Security Audit';
      case LifecyclePhase.launch:
        return '7. Launch & Deployment';
      case LifecyclePhase.handover:
        return '8. Handover & Documentation';
      case LifecyclePhase.support:
        return '9. Support & Retainer';
    }
  }
}

/// Importance of a checklist item — critical gates cannot be skipped.
enum ChecklistSeverity { critical, required, recommended }

extension ChecklistSeverityX on ChecklistSeverity {
  String get label {
    switch (this) {
      case ChecklistSeverity.critical:
        return 'Critical';
      case ChecklistSeverity.required:
        return 'Required';
      case ChecklistSeverity.recommended:
        return 'Recommended';
    }
  }
}

/// A single checklist item definition inside a template.
class ChecklistItemDef {
  final String id;
  final String title;
  final String detail;
  final ChecklistSeverity severity;

  const ChecklistItemDef({
    required this.id,
    required this.title,
    this.detail = '',
    this.severity = ChecklistSeverity.required,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'detail': detail,
        'severity': severity.name,
      };

  factory ChecklistItemDef.fromJson(Map<dynamic, dynamic> json) =>
      ChecklistItemDef(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        detail: json['detail']?.toString() ?? '',
        severity: ChecklistSeverity.values.firstWhere(
          (s) => s.name == json['severity'],
          orElse: () => ChecklistSeverity.required,
        ),
      );
}

/// One phase of a template.
class ChecklistPhaseDef {
  final LifecyclePhase phase;
  final List<ChecklistItemDef> items;

  const ChecklistPhaseDef({required this.phase, required this.items});

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'items': items.map((i) => i.toJson()).toList(),
      };

  factory ChecklistPhaseDef.fromJson(Map<dynamic, dynamic> json) =>
      ChecklistPhaseDef(
        phase: LifecyclePhase.values.firstWhere(
          (p) => p.name == json['phase'],
          orElse: () => LifecyclePhase.discovery,
        ),
        items: (json['items'] as List?)
                ?.map((i) =>
                    ChecklistItemDef.fromJson(Map<String, dynamic>.from(i)))
                .toList() ??
            [],
      );
}

/// A template: one of the three separate tracks.
class ChecklistTemplate {
  final ChecklistTrack track;
  final List<ChecklistPhaseDef> phases;

  const ChecklistTemplate({required this.track, required this.phases});

  int get totalItems =>
      phases.fold(0, (sum, p) => sum + p.items.length);
}

/// A persisted, per-project instance of a template with live check state.
class ChecklistInstance {
  final String id; // e.g. the project/lead id this checklist belongs to
  final ChecklistTrack track;
  final String projectName;
  final Map<String, bool> checked; // itemId → done
  final DateTime createdAt;
  final DateTime updatedAt;

  ChecklistInstance({
    required this.id,
    required this.track,
    required this.projectName,
    Map<String, bool>? checked,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : checked = checked ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  ChecklistTemplate get template => templateFor(track);

  double get progress {
    final total = template.totalItems;
    if (total == 0) return 0;
    final done = checked.values.where((v) => v).length;
    return done / total;
  }

  int get doneCount => checked.values.where((v) => v).length;
  int get totalCount => template.totalItems;

  bool get allCriticalDone {
    for (final phase in template.phases) {
      for (final item in phase.items) {
        if (item.severity == ChecklistSeverity.critical && checked[item.id] != true) {
          return false;
        }
      }
    }
    return true;
  }

  ChecklistInstance copyWith({
    Map<String, bool>? checked,
    DateTime? updatedAt,
  }) {
    return ChecklistInstance(
      id: id,
      track: track,
      projectName: projectName,
      checked: checked ?? this.checked,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'track': track.name,
        'projectName': projectName,
        'checked': checked,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ChecklistInstance.fromJson(Map<dynamic, dynamic> json) =>
      ChecklistInstance(
        id: json['id']?.toString() ?? '',
        track: ChecklistTrackX.fromName(json['track']?.toString()),
        projectName: json['projectName']?.toString() ?? '',
        checked: (json['checked'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), v == true)) ??
            {},
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

// ════════════════════════════════════════════════════════════════════════════
// Template definitions — the three separate lifecycle checklists.
// Shared cross-cutting gates (DPDP Act 2023 + security) appear in every track;
// discipline-specific items differ per track.
// ════════════════════════════════════════════════════════════════════════════

const _sharedAgreementCompliance = ChecklistPhaseDef(
  phase: LifecyclePhase.agreement,
  items: [
    ChecklistItemDef(
      id: 'agr_contract',
      title: 'Signed SOW / contract with milestone schedule',
      detail: 'Scope, deliverables, payment milestones and IP transfer clause.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'agr_nda',
      title: 'Mutual NDA executed (if requested)',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'agr_dpdp_notice',
      title: 'DPDP Act 2023 — privacy notice prepared for the product',
      detail:
          'Clear, itemised notice of what personal data is collected, purpose, retention and grievance officer contact.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'agr_dpdp_consent',
      title: 'DPDP Act 2023 — consent flows specified',
      detail:
          'Explicit, informed, purpose-limited consent for data collection; easy withdrawal mechanism.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'agr_data_map',
      title: 'Data inventory & processing map drafted',
      detail:
          'What personal data, where stored, who processes it, sub-processors listed.',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'agr_security_baseline',
      title: 'Security baseline agreed with client',
      detail:
          'Encryption standards, access policy, logging and incident response expectations.',
      severity: ChecklistSeverity.required,
    ),
  ],
);

const _sharedQaSecurity = ChecklistPhaseDef(
  phase: LifecyclePhase.qaSecurity,
  items: [
    ChecklistItemDef(
      id: 'qa_functional',
      title: 'Full functional test pass on staging',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'qa_cross',
      title: 'Cross-browser / cross-device matrix verified',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'sec_owasp',
      title: 'OWASP Top 10 review completed',
      detail:
          'Injection, broken auth, sensitive data exposure, XSS, misconfig, IDOR logged and fixed.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'sec_https',
      title: 'HTTPS enforced, TLS 1.2+ only, HSTS enabled',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'sec_headers',
      title: 'Security headers set',
      detail: 'CSP, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Permissions-Policy.',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'sec_auth',
      title: 'Auth hardening verified',
      detail:
          'Rate limiting, lockout, strong password policy, secure session handling, OAuth/OIDC where applicable.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'sec_encryption',
      title: 'Encryption at rest & in transit verified',
      detail: 'AES-256 at rest, TLS in transit, secrets in a managed vault — never in code.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'sec_backup',
      title: 'Backup & restore drill executed',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'sec_deps',
      title: 'Dependency audit clean (no known CVEs)',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'dpdp_erasure',
      title: 'DPDP Act 2023 — data erasure & correction flows tested',
      detail:
          'Data principal can access, correct and erase their personal data end-to-end.',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'dpdp_breach',
      title: 'DPDP Act 2023 — breach reporting playbook documented',
      detail:
          'Breaches must be reported to the Data Protection Board and affected users without delay.',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'dpdp_children',
      title: 'DPDP Act 2023 — children’s data safeguards (if applicable)',
      detail: 'Verifiable parental consent and no tracking/behavioural ads for minors.',
      severity: ChecklistSeverity.recommended,
    ),
  ],
);

const _sharedHandover = ChecklistPhaseDef(
  phase: LifecyclePhase.handover,
  items: [
    ChecklistItemDef(
      id: 'ho_repo',
      title: 'Repository + infrastructure access transferred',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'ho_docs',
      title: 'Technical documentation & runbook delivered',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'ho_credentials',
      title: 'Credential vault handed over; studio access revoked',
      severity: ChecklistSeverity.critical,
    ),
    ChecklistItemDef(
      id: 'ho_training',
      title: 'Client team walkthrough / training session done',
      severity: ChecklistSeverity.recommended,
    ),
  ],
);

const _sharedSupport = ChecklistPhaseDef(
  phase: LifecyclePhase.support,
  items: [
    ChecklistItemDef(
      id: 'sup_warranty',
      title: '60-day post-launch warranty window active',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'sup_monitoring',
      title: 'Uptime + error monitoring configured',
      severity: ChecklistSeverity.required,
    ),
    ChecklistItemDef(
      id: 'sup_updates',
      title: 'Patch cadence scheduled (security updates)',
      severity: ChecklistSeverity.recommended,
    ),
  ],
);

const _websiteTemplate = ChecklistTemplate(
  track: ChecklistTrack.website,
  phases: [
    ChecklistPhaseDef(
      phase: LifecyclePhase.discovery,
      items: [
        ChecklistItemDef(
          id: 'web_disc_brand',
          title: 'Brand & positioning workshop completed',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'web_disc_sitemap',
          title: 'Sitemap & page inventory signed off',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_disc_content',
          title: 'Content ownership & delivery plan confirmed',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'web_disc_ref',
          title: 'Reference sites & anti-goals collected',
          severity: ChecklistSeverity.recommended,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.proposal,
      items: [
        ChecklistItemDef(
          id: 'web_prop_scope',
          title: 'Page-by-page scope & quote delivered',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_prop_perf',
          title: 'Performance budget committed (LCP < 2.5s, P99 < 50ms)',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedAgreementCompliance,
    ChecklistPhaseDef(
      phase: LifecyclePhase.design,
      items: [
        ChecklistItemDef(
          id: 'web_des_wire',
          title: 'Wireframes approved for all key pages',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'web_des_ui',
          title: 'High-fidelity UI (desktop + mobile) approved',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_des_a11y',
          title: 'Accessibility pass on designs (contrast, focus, ARIA plan)',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.development,
      items: [
        ChecklistItemDef(
          id: 'web_dev_responsive',
          title: 'Responsive build verified at 5 breakpoints',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_dev_corevit',
          title: 'Core Web Vitals in the green (LCP/CLS/INP)',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_dev_cms',
          title: 'CMS / content editing flows wired & tested',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'web_dev_seo',
          title: 'Technical SEO: meta, OG, sitemap.xml, robots.txt, canonicals',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'web_dev_analytics',
          title: 'Privacy-friendly analytics wired (consent-gated)',
          severity: ChecklistSeverity.recommended,
        ),
      ],
    ),
    _sharedQaSecurity,
    ChecklistPhaseDef(
      phase: LifecyclePhase.launch,
      items: [
        ChecklistItemDef(
          id: 'web_launch_dns',
          title: 'DNS, SSL and CDN (Cloudflare) configured',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_launch_forms',
          title: 'All forms / WhatsApp lead pipeline tested end-to-end',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'web_launch_redirects',
          title: 'Redirect map applied; 404 page customised',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedHandover,
    _sharedSupport,
  ],
);

const _softwareTemplate = ChecklistTemplate(
  track: ChecklistTrack.software,
  phases: [
    ChecklistPhaseDef(
      phase: LifecyclePhase.discovery,
      items: [
        ChecklistItemDef(
          id: 'sw_disc_process',
          title: 'Business process mapping (as-is → to-be) signed off',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_disc_stake',
          title: 'Stakeholder & role matrix documented',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'sw_disc_integration',
          title: 'Integration inventory (Tally, WhatsApp, payment, etc.) listed',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'sw_disc_data',
          title: 'Legacy data audit & migration plan drafted',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.proposal,
      items: [
        ChecklistItemDef(
          id: 'sw_prop_arch',
          title: 'High-level architecture diagram shared with quote',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_prop_licenses',
          title: 'Licence / infrastructure cost projection included',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedAgreementCompliance,
    ChecklistPhaseDef(
      phase: LifecyclePhase.design,
      items: [
        ChecklistItemDef(
          id: 'sw_des_data',
          title: 'Data model & ERD approved',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_des_rbac',
          title: 'Role-based access control matrix defined',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_des_flows',
          title: 'Core workflow wireframes approved',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.development,
      items: [
        ChecklistItemDef(
          id: 'sw_dev_uat',
          title: 'Module-wise UAT with real users after each milestone',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_dev_migrations',
          title: 'Data migration scripts rehearsed on staging copy',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_dev_audit',
          title: 'Audit logging for sensitive operations implemented',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'sw_dev_api',
          title: 'API contract documented (OpenAPI) & versioned',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedQaSecurity,
    ChecklistPhaseDef(
      phase: LifecyclePhase.launch,
      items: [
        ChecklistItemDef(
          id: 'sw_launch_cutover',
          title: 'Go-live cutover plan with rollback steps',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'sw_launch_training',
          title: 'End-user training completed for each role',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'sw_launch_hypercare',
          title: 'Hypercare window (2 weeks) staffed',
          severity: ChecklistSeverity.recommended,
        ),
      ],
    ),
    _sharedHandover,
    _sharedSupport,
  ],
);

const _webappTemplate = ChecklistTemplate(
  track: ChecklistTrack.webapp,
  phases: [
    ChecklistPhaseDef(
      phase: LifecyclePhase.discovery,
      items: [
        ChecklistItemDef(
          id: 'wa_disc_personas',
          title: 'User personas & permission tiers defined',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_disc_scale',
          title: 'Scale targets agreed (concurrent users, data volume)',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'wa_disc_monetise',
          title: 'Monetisation & billing model confirmed',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.proposal,
      items: [
        ChecklistItemDef(
          id: 'wa_prop_stack',
          title: 'Cloud architecture & stack proposal approved',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_prop_sla',
          title: 'Uptime SLA & DR targets (RPO/RTO) committed',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedAgreementCompliance,
    ChecklistPhaseDef(
      phase: LifecyclePhase.design,
      items: [
        ChecklistItemDef(
          id: 'wa_des_multi',
          title: 'Multi-tenancy / data isolation design approved',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_des_realtime',
          title: 'Real-time sync & conflict strategy defined',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'wa_des_design',
          title: 'Product UI system (components + states) approved',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    ChecklistPhaseDef(
      phase: LifecyclePhase.development,
      items: [
        ChecklistItemDef(
          id: 'wa_dev_auth',
          title: 'Auth (sign-up, SSO/OAuth, MFA-ready) implemented',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_dev_payments',
          title: 'Billing / subscription flows tested (webhooks, retries)',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'wa_dev_scale',
          title: 'Load test at 2× target concurrency passed',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_dev_obs',
          title: 'Observability: structured logs, traces, alerts wired',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedQaSecurity,
    ChecklistPhaseDef(
      phase: LifecyclePhase.launch,
      items: [
        ChecklistItemDef(
          id: 'wa_launch_infra',
          title: 'Production infra as code; autoscaling verified',
          severity: ChecklistSeverity.critical,
        ),
        ChecklistItemDef(
          id: 'wa_launch_status',
          title: 'Status page & incident comms channel live',
          severity: ChecklistSeverity.required,
        ),
        ChecklistItemDef(
          id: 'wa_launch_drill',
          title: 'Disaster-recovery drill completed',
          severity: ChecklistSeverity.required,
        ),
      ],
    ),
    _sharedHandover,
    _sharedSupport,
  ],
);

final Map<ChecklistTrack, ChecklistTemplate> _templates = {
  ChecklistTrack.website: _websiteTemplate,
  ChecklistTrack.software: _softwareTemplate,
  ChecklistTrack.webapp: _webappTemplate,
};

ChecklistTemplate templateFor(ChecklistTrack track) =>
    _templates[track] ?? _websiteTemplate;

/// Create a fresh instance for a project with everything unchecked.
ChecklistInstance createChecklistInstance({
  required String id,
  required ChecklistTrack track,
  required String projectName,
}) {
  final template = templateFor(track);
  return ChecklistInstance(
    id: id,
    track: track,
    projectName: projectName,
    checked: {
      for (final phase in template.phases)
        for (final item in phase.items) item.id: false,
    },
  );
}
