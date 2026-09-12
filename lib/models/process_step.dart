/// The 11-step Bitnexel delivery process — mirrors the website's "11-Step
/// Product Lifecycle" so every project can be tracked against the exact steps
/// the client is promised.
library;

enum ProcessStep {
  firstContact,
  qualification,
  proposal,
  kickoff,
  discovery,
  design,
  development,
  qa,
  review,
  launch,
  warranty,
}

extension ProcessStepX on ProcessStep {
  int get index => ProcessStep.values.indexOf(this);
  int get number => index + 1;

  static int get total => ProcessStep.values.length;

  static ProcessStep fromIndex(int i) {
    final clamped = i.clamp(0, ProcessStep.values.length - 1);
    return ProcessStep.values[clamped];
  }

  String get label {
    switch (this) {
      case ProcessStep.firstContact:
        return 'First Contact & Fit';
      case ProcessStep.qualification:
        return 'Qualification Alignment';
      case ProcessStep.proposal:
        return 'Proposal & Master SOW';
      case ProcessStep.kickoff:
        return 'Deposit & Portal Kickoff';
      case ProcessStep.discovery:
        return 'Discovery & Spec Definition';
      case ProcessStep.design:
        return 'Bespoke UI/UX Design';
      case ProcessStep.development:
        return 'Sprint Engineering';
      case ProcessStep.qa:
        return 'Rigorous QA & Auditing';
      case ProcessStep.review:
        return 'Final Review & Sign-Off';
      case ProcessStep.launch:
        return 'DNS Cutover & Launch';
      case ProcessStep.warranty:
        return 'Post-Launch Warranty & Retainer';
    }
  }

  String get shortLabel {
    switch (this) {
      case ProcessStep.firstContact:
        return 'First Contact';
      case ProcessStep.qualification:
        return 'Qualification';
      case ProcessStep.proposal:
        return 'Proposal';
      case ProcessStep.kickoff:
        return 'Kickoff';
      case ProcessStep.discovery:
        return 'Discovery';
      case ProcessStep.design:
        return 'UI/UX Design';
      case ProcessStep.development:
        return 'Engineering';
      case ProcessStep.qa:
        return 'QA & Audit';
      case ProcessStep.review:
        return 'Final Review';
      case ProcessStep.launch:
        return 'Launch';
      case ProcessStep.warranty:
        return 'Warranty';
    }
  }

  String get description {
    switch (this) {
      case ProcessStep.firstContact:
        return 'Structured intake and feasibility response within 24 hours.';
      case ProcessStep.qualification:
        return 'Honest scoping alignment and budget/timeline confirmation.';
      case ProcessStep.proposal:
        return 'Fixed-price, milestone-driven statement of work.';
      case ProcessStep.kickoff:
        return 'Private portal, staging environment, and 50% deposit.';
      case ProcessStep.discovery:
        return 'User journeys, schemas and edge cases mapped.';
      case ProcessStep.design:
        return 'Bespoke UI/UX and interactive prototype.';
      case ProcessStep.development:
        return 'Clean TypeScript engineering with weekly staging.';
      case ProcessStep.qa:
        return 'Cross-device testing, security and performance audit.';
      case ProcessStep.review:
        return 'Staging sign-off and 30% milestone.';
      case ProcessStep.launch:
        return 'Zero-downtime DNS cutover and repo transfer.';
      case ProcessStep.warranty:
        return '60-day warranty and optional retainer.';
    }
  }
}
