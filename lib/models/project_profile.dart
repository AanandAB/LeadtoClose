class ProjectProfile {
  // Section 1: Project Type & Scope
  final String projectType;
  final String projectCategory; // website vs software platform
  final List<String> features;
  final String projectTier;

  // Section 2: Client Details
  final String clientLocation;
  final bool clientIsStartup;
  final String clientIndustry;

  // Section 3: Data & Privacy
  final bool collectsPersonalData;
  final List<String> dataTypes;
  final bool processesChildData;
  final List<String> targetAudience;
  final bool needsRegionalLanguage;

  // Section 4: Commerce & Payments
  final String paymentType;
  final String goodsType;
  final bool hasPreCheckedBoxes;

  // Section 5: Hosting & Maintenance
  final String hostingType;
  final bool providesMaintenance;
  final bool hasProductionAccess;

  // Section 6: IP & Assets
  final String ipOwnership;
  final bool usesThirdPartyAssets;
  final bool willReuseCode;
  final bool isResellable;

  // Section 7: Legal & Contract
  final String paymentTerms;
  final bool needsSLA;
  final bool developerDraftsTerms;
  final String ongoingRelationship;

  const ProjectProfile({
    this.projectType = 'Brochure/Portfolio site',
    this.projectCategory = 'Website',
    this.features = const [],
    this.projectTier = 'Standard (dynamic/CMS)',
    this.clientLocation = 'Same state as me',
    this.clientIsStartup = false,
    this.clientIndustry = 'Other',
    this.collectsPersonalData = false,
    this.dataTypes = const [],
    this.processesChildData = false,
    this.targetAudience = const [],
    this.needsRegionalLanguage = false,
    this.paymentType = 'No',
    this.goodsType = 'N/A',
    this.hasPreCheckedBoxes = false,
    this.hostingType = 'No, handover only',
    this.providesMaintenance = false,
    this.hasProductionAccess = false,
    this.ipOwnership = 'Not yet discussed',
    this.usesThirdPartyAssets = false,
    this.willReuseCode = false,
    this.isResellable = false,
    this.paymentTerms = '50% advance, 50% on delivery',
    this.needsSLA = false,
    this.developerDraftsTerms = false,
    this.ongoingRelationship = 'One-time project',
  });

  // Convenience getters
  bool get requiresHosting => hostingType != 'No, handover only';
  bool get isHostingAndMaintaining => hostingType == 'Yes - hosting + ongoing maintenance' || providesMaintenance;
  bool get acceptsPayments => paymentType != 'No';
  bool get sellsPhysicalGoods => goodsType == 'Physical goods';
  bool get isExport => clientLocation == 'Outside India';
  bool get isInterState => clientLocation == 'Different Indian state';
  bool get targetsEU => targetAudience.contains('EU');
  bool get targetsUS => targetAudience.contains('US/California');
  bool get isSaaS => projectCategory == 'Software Platform';
  bool get isEcommerce => projectType == 'E-commerce/Shop' || (projectType == 'Custom Web App' && acceptsPayments);
  bool get wantsFullOwnership => ipOwnership == 'Wants full ownership';
  bool get isRetainer => ongoingRelationship == 'Retainer/ongoing';
  bool get collectsFinancialData => dataTypes.contains('Financial/payment data');
  bool get collectsHealthData => dataTypes.contains('Health/medical data');
  bool get isYouDataFiduciary => requiresHosting && hasProductionAccess;

  Map<String, dynamic> toJson() => {
    'projectType': projectType, 'projectCategory': projectCategory,
    'features': features, 'projectTier': projectTier,
    'clientLocation': clientLocation, 'clientIsStartup': clientIsStartup,
    'clientIndustry': clientIndustry, 'collectsPersonalData': collectsPersonalData,
    'dataTypes': dataTypes, 'processesChildData': processesChildData,
    'targetAudience': targetAudience, 'needsRegionalLanguage': needsRegionalLanguage,
    'paymentType': paymentType, 'goodsType': goodsType,
    'hasPreCheckedBoxes': hasPreCheckedBoxes,
    'hostingType': hostingType, 'providesMaintenance': providesMaintenance,
    'hasProductionAccess': hasProductionAccess,
    'ipOwnership': ipOwnership, 'usesThirdPartyAssets': usesThirdPartyAssets,
    'willReuseCode': willReuseCode, 'isResellable': isResellable,
    'paymentTerms': paymentTerms, 'needsSLA': needsSLA,
    'developerDraftsTerms': developerDraftsTerms,
    'ongoingRelationship': ongoingRelationship,
  };

  factory ProjectProfile.fromJson(Map<dynamic, dynamic> json) => ProjectProfile(
    projectType: json['projectType']?.toString() ?? 'Brochure/Portfolio site',
    projectCategory: json['projectCategory']?.toString() ?? 'Website',
    features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
    projectTier: json['projectTier']?.toString() ?? 'Standard (dynamic/CMS)',
    clientLocation: json['clientLocation']?.toString() ?? 'Same state as me',
    clientIsStartup: json['clientIsStartup'] == true,
    clientIndustry: json['clientIndustry']?.toString() ?? 'Other',
    collectsPersonalData: json['collectsPersonalData'] == true,
    dataTypes: (json['dataTypes'] as List?)?.map((e) => e.toString()).toList() ?? [],
    processesChildData: json['processesChildData'] == true,
    targetAudience: (json['targetAudience'] as List?)?.map((e) => e.toString()).toList() ?? [],
    needsRegionalLanguage: json['needsRegionalLanguage'] == true,
    paymentType: json['paymentType']?.toString() ?? 'No',
    goodsType: json['goodsType']?.toString() ?? 'N/A',
    hasPreCheckedBoxes: json['hasPreCheckedBoxes'] == true,
    hostingType: json['hostingType']?.toString() ?? 'No, handover only',
    providesMaintenance: json['providesMaintenance'] == true,
    hasProductionAccess: json['hasProductionAccess'] == true,
    ipOwnership: json['ipOwnership']?.toString() ?? 'Not yet discussed',
    usesThirdPartyAssets: json['usesThirdPartyAssets'] == true,
    willReuseCode: json['willReuseCode'] == true,
    isResellable: json['isResellable'] == true,
    paymentTerms: json['paymentTerms']?.toString() ?? '50% advance, 50% on delivery',
    needsSLA: json['needsSLA'] == true,
    developerDraftsTerms: json['developerDraftsTerms'] == true,
    ongoingRelationship: json['ongoingRelationship']?.toString() ?? 'One-time project',
  );
}
