class Client {
  final String id;
  final String companyName;
  final List<Contact> contacts;
  final String industry;
  final String website;
  final String address;
  final String notes;
  final String healthScore; // active, at-risk, dormant
  final List<String> tags;
  final Map<String, String> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double totalRevenue;
  final double outstandingBalance;

  Client({
    required this.id,
    required this.companyName,
    this.contacts = const [],
    this.industry = '',
    this.website = '',
    this.address = '',
    this.notes = '',
    this.healthScore = 'active',
    this.tags = const [],
    this.customFields = const {},
    DateTime? createdAt,
    DateTime? updatedAt,
    this.totalRevenue = 0,
    this.outstandingBalance = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Contact? get primaryContact =>
      contacts.isNotEmpty ? contacts.first : null;

  Client copyWith({
    String? companyName,
    List<Contact>? contacts,
    String? industry,
    String? website,
    String? address,
    String? notes,
    String? healthScore,
    List<String>? tags,
    Map<String, String>? customFields,
    DateTime? updatedAt,
    double? totalRevenue,
    double? outstandingBalance,
  }) {
    return Client(
      id: id,
      companyName: companyName ?? this.companyName,
      contacts: contacts ?? this.contacts,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      healthScore: healthScore ?? this.healthScore,
      tags: tags ?? this.tags,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      totalRevenue: totalRevenue ?? this.totalRevenue,
      outstandingBalance: outstandingBalance ?? this.outstandingBalance,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'companyName': companyName,
        'contacts': contacts.map((c) => c.toJson()).toList(),
        'industry': industry,
        'website': website,
        'address': address,
        'notes': notes,
        'healthScore': healthScore,
        'tags': tags,
        'customFields': customFields,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'totalRevenue': totalRevenue,
        'outstandingBalance': outstandingBalance,
      };

  factory Client.fromJson(Map<dynamic, dynamic> json) => Client(
        id: json['id']?.toString() ?? '',
        companyName: json['companyName']?.toString() ?? '',
        contacts: (json['contacts'] as List?)
                ?.map((c) =>
                    Contact.fromJson(Map<String, dynamic>.from(c)))
                .toList() ??
            [],
        industry: json['industry']?.toString() ?? '',
        website: json['website']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
        healthScore: json['healthScore']?.toString() ?? 'active',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        customFields: (json['customFields'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
            {},
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
        outstandingBalance:
            (json['outstandingBalance'] as num?)?.toDouble() ?? 0,
      );
}

class Contact {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isPrimary;

  Contact({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.role = '',
    this.isPrimary = false,
  });

  Contact copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isPrimary,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'isPrimary': isPrimary,
      };

  factory Contact.fromJson(Map<dynamic, dynamic> json) => Contact(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
        isPrimary: json['isPrimary'] == true,
      );
}
