
class BusinessProfile {
  final String businessName;
  final String ownerName;
  final String businessStructure; // Sole Proprietor, OPC, LLP
  final String pan;
  final String gstin;
  final String udyamNumber;
  final String homeState;
  final String bankDetails;
  final String email;
  final String phone;
  final double lateFeePercent;
  final List<String> foreignPaymentPlatforms;

  const BusinessProfile({
    this.businessName = '',
    this.ownerName = '',
    this.businessStructure = 'Sole Proprietor',
    this.pan = '',
    this.gstin = '',
    this.udyamNumber = '',
    this.homeState = 'Kerala',
    this.bankDetails = '',
    this.email = '',
    this.phone = '',
    this.lateFeePercent = 18.0,
    this.foreignPaymentPlatforms = const [],
  });

  bool get isGstRegistered => gstin.isNotEmpty;
  bool get isUdyamRegistered => udyamNumber.isNotEmpty;
  bool get isComplete => businessName.isNotEmpty && ownerName.isNotEmpty && pan.isNotEmpty;

  BusinessProfile copyWith({
    String? businessName, String? ownerName, String? businessStructure,
    String? pan, String? gstin, String? udyamNumber, String? homeState,
    String? bankDetails, String? email, String? phone,
    double? lateFeePercent, List<String>? foreignPaymentPlatforms,
  }) {
    return BusinessProfile(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      businessStructure: businessStructure ?? this.businessStructure,
      pan: pan ?? this.pan, gstin: gstin ?? this.gstin,
      udyamNumber: udyamNumber ?? this.udyamNumber,
      homeState: homeState ?? this.homeState,
      bankDetails: bankDetails ?? this.bankDetails,
      email: email ?? this.email, phone: phone ?? this.phone,
      lateFeePercent: lateFeePercent ?? this.lateFeePercent,
      foreignPaymentPlatforms: foreignPaymentPlatforms ?? this.foreignPaymentPlatforms,
    );
  }

  Map<String, dynamic> toJson() => {
    'businessName': businessName, 'ownerName': ownerName,
    'businessStructure': businessStructure, 'pan': pan,
    'gstin': gstin, 'udyamNumber': udyamNumber,
    'homeState': homeState, 'bankDetails': bankDetails,
    'email': email, 'phone': phone,
    'lateFeePercent': lateFeePercent,
    'foreignPaymentPlatforms': foreignPaymentPlatforms,
  };

  factory BusinessProfile.fromJson(Map<dynamic, dynamic> json) => BusinessProfile(
    businessName: json['businessName']?.toString() ?? '',
    ownerName: json['ownerName']?.toString() ?? '',
    businessStructure: json['businessStructure']?.toString() ?? 'Sole Proprietor',
    pan: json['pan']?.toString() ?? '',
    gstin: json['gstin']?.toString() ?? '',
    udyamNumber: json['udyamNumber']?.toString() ?? '',
    homeState: json['homeState']?.toString() ?? 'Kerala',
    bankDetails: json['bankDetails']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phone: json['phone']?.toString() ?? '',
    lateFeePercent: (json['lateFeePercent'] as num?)?.toDouble() ?? 18.0,
    foreignPaymentPlatforms: (json['foreignPaymentPlatforms'] as List?)?.map((e) => e.toString()).toList() ?? [],
  );
}
