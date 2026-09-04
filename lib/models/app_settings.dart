class AppSettings {
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String website;
  final String address;
  final String currency;
  final String currencySymbol;
  final String timezone;
  final String accentColor;
  final String logoPath;
  final String defaultPaymentTerms; // Net 15, Net 30, Net 60
  final double defaultTaxRate;
  final String taxLabel; // GST, VAT, etc.
  final bool isDarkMode;
  final String invoicePrefix;
  final int invoiceNextNumber;
  final String quotePrefix;
  final int quoteNextNumber;
  final String contractPrefix;
  final int contractNextNumber;
  final List<String> integrations; // enabled integrations
  final String teamRole; // admin, member, viewer
  final DateTime createdAt;

  AppSettings({
    this.businessName = '',
    this.ownerName = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.address = '',
    this.currency = 'USD',
    this.currencySymbol = '\$',
    this.timezone = 'UTC',
    this.accentColor = '#3B82F6',
    this.logoPath = '',
    this.defaultPaymentTerms = 'Net 30',
    this.defaultTaxRate = 0,
    this.taxLabel = 'Tax',
    this.isDarkMode = false,
    this.invoicePrefix = 'INV',
    this.invoiceNextNumber = 1001,
    this.quotePrefix = 'Q',
    this.quoteNextNumber = 1001,
    this.contractPrefix = 'CTR',
    this.contractNextNumber = 1001,
    this.integrations = const [],
    this.teamRole = 'admin',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isComplete => businessName.isNotEmpty && ownerName.isNotEmpty;

  AppSettings copyWith({
    String? businessName,
    String? ownerName,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? currency,
    String? currencySymbol,
    String? timezone,
    String? accentColor,
    String? logoPath,
    String? defaultPaymentTerms,
    double? defaultTaxRate,
    String? taxLabel,
    bool? isDarkMode,
    String? invoicePrefix,
    int? invoiceNextNumber,
    String? quotePrefix,
    int? quoteNextNumber,
    String? contractPrefix,
    int? contractNextNumber,
    List<String>? integrations,
    String? teamRole,
  }) {
    return AppSettings(
      businessName: businessName ?? this.businessName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      timezone: timezone ?? this.timezone,
      accentColor: accentColor ?? this.accentColor,
      logoPath: logoPath ?? this.logoPath,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      taxLabel: taxLabel ?? this.taxLabel,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceNextNumber: invoiceNextNumber ?? this.invoiceNextNumber,
      quotePrefix: quotePrefix ?? this.quotePrefix,
      quoteNextNumber: quoteNextNumber ?? this.quoteNextNumber,
      contractPrefix: contractPrefix ?? this.contractPrefix,
      contractNextNumber: contractNextNumber ?? this.contractNextNumber,
      integrations: integrations ?? this.integrations,
      teamRole: teamRole ?? this.teamRole,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'businessName': businessName,
        'ownerName': ownerName,
        'email': email,
        'phone': phone,
        'website': website,
        'address': address,
        'currency': currency,
        'currencySymbol': currencySymbol,
        'timezone': timezone,
        'accentColor': accentColor,
        'logoPath': logoPath,
        'defaultPaymentTerms': defaultPaymentTerms,
        'defaultTaxRate': defaultTaxRate,
        'taxLabel': taxLabel,
        'isDarkMode': isDarkMode,
        'invoicePrefix': invoicePrefix,
        'invoiceNextNumber': invoiceNextNumber,
        'quotePrefix': quotePrefix,
        'quoteNextNumber': quoteNextNumber,
        'contractPrefix': contractPrefix,
        'contractNextNumber': contractNextNumber,
        'integrations': integrations,
        'teamRole': teamRole,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        businessName: json['businessName']?.toString() ?? '',
        ownerName: json['ownerName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        website: json['website']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        currency: json['currency']?.toString() ?? 'USD',
        currencySymbol: json['currencySymbol']?.toString() ?? '\$',
        timezone: json['timezone']?.toString() ?? 'UTC',
        accentColor: json['accentColor']?.toString() ?? '#3B82F6',
        logoPath: json['logoPath']?.toString() ?? '',
        defaultPaymentTerms:
            json['defaultPaymentTerms']?.toString() ?? 'Net 30',
        defaultTaxRate: (json['defaultTaxRate'] as num?)?.toDouble() ?? 0,
        taxLabel: json['taxLabel']?.toString() ?? 'Tax',
        isDarkMode: json['isDarkMode'] != false,
        invoicePrefix: json['invoicePrefix']?.toString() ?? 'INV',
        invoiceNextNumber: (json['invoiceNextNumber'] as num?)?.toInt() ?? 1001,
        quotePrefix: json['quotePrefix']?.toString() ?? 'Q',
        quoteNextNumber: (json['quoteNextNumber'] as num?)?.toInt() ?? 1001,
        contractPrefix: json['contractPrefix']?.toString() ?? 'CTR',
        contractNextNumber:
            (json['contractNextNumber'] as num?)?.toInt() ?? 1001,
        integrations: (json['integrations'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        teamRole: json['teamRole']?.toString() ?? 'admin',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
