
class ProjectProfile {
  final String projectType;
  final bool collectsPersonalData;
  final String paymentType;
  final String goodsType;
  final String clientLocation;
  final String hostingType;
  final List<String> targetAudience;
  final String projectTier;
  final String ipOwnership;
  final bool processesChildData;
  final String ongoingRelationship;

  const ProjectProfile({
    this.projectType = 'Brochure/Portfolio site',
    this.collectsPersonalData = false,
    this.paymentType = 'No',
    this.goodsType = 'N/A',
    this.clientLocation = 'Same state as me',
    this.hostingType = 'No, handover only',
    this.targetAudience = const [],
    this.projectTier = 'Standard (dynamic/CMS)',
    this.ipOwnership = 'Not yet discussed',
    this.processesChildData = false,
    this.ongoingRelationship = 'One-time project',
  });

  bool get requiresHosting => hostingType != 'No, handover only';
  bool get requiresMaintenance => hostingType == 'Yes - hosting + ongoing maintenance';
  bool get acceptsPayments => paymentType != 'No';
  bool get sellsPhysicalGoods => goodsType == 'Physical goods';
  bool get isExport => clientLocation == 'Outside India';
  bool get isInterState => clientLocation == 'Different Indian state';
  bool get targetsEU => targetAudience.contains('EU');
  bool get targetsUS => targetAudience.contains('US/California');
  bool get isSaas => projectType == 'CRM/ERP/SaaS';
  bool get wantsFullOwnership => ipOwnership == 'Wants full ownership';
  bool get isRetainer => ongoingRelationship == 'Retainer/ongoing';

  Map<String, dynamic> toJson() => {
    'projectType': projectType, 'collectsPersonalData': collectsPersonalData,
    'paymentType': paymentType, 'goodsType': goodsType,
    'clientLocation': clientLocation, 'hostingType': hostingType,
    'targetAudience': targetAudience, 'projectTier': projectTier,
    'ipOwnership': ipOwnership, 'processesChildData': processesChildData,
    'ongoingRelationship': ongoingRelationship,
  };

  factory ProjectProfile.fromJson(Map<dynamic, dynamic> json) => ProjectProfile(
    projectType: json['projectType']?.toString() ?? 'Brochure/Portfolio site',
    collectsPersonalData: json['collectsPersonalData'] == true,
    paymentType: json['paymentType']?.toString() ?? 'No',
    goodsType: json['goodsType']?.toString() ?? 'N/A',
    clientLocation: json['clientLocation']?.toString() ?? 'Same state as me',
    hostingType: json['hostingType']?.toString() ?? 'No, handover only',
    targetAudience: (json['targetAudience'] as List?)?.map((e) => e.toString()).toList() ?? [],
    projectTier: json['projectTier']?.toString() ?? 'Standard (dynamic/CMS)',
    ipOwnership: json['ipOwnership']?.toString() ?? 'Not yet discussed',
    processesChildData: json['processesChildData'] == true,
    ongoingRelationship: json['ongoingRelationship']?.toString() ?? 'One-time project',
  );
}
