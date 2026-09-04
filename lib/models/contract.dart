enum ContractStatus { draft, sent, signed, active, completed, expired }

class Contract {
  final String id;
  final String number;
  final String clientId;
  final String projectId;
  final String quoteId;
  final String title;
  final String type; // NDA, MSA, SOW, retainer, custom
  final List<ContractClause> clauses;
  final String status;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? signedAt;
  final DateTime? expiresAt;
  final String signerName;
  final String signerEmail;
  final String notes;

  Contract({
    required this.id,
    required this.number,
    this.clientId = '',
    this.projectId = '',
    this.quoteId = '',
    this.title = '',
    this.type = 'SOW',
    this.clauses = const [],
    this.status = 'draft',
    DateTime? createdAt,
    this.sentAt,
    this.signedAt,
    this.expiresAt,
    this.signerName = '',
    this.signerEmail = '',
    this.notes = '',
  }) : createdAt = createdAt ?? DateTime.now();

  ContractStatus get contractStatus => ContractStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ContractStatus.draft,
      );

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Contract copyWith({
    String? number,
    String? clientId,
    String? projectId,
    String? quoteId,
    String? title,
    String? type,
    List<ContractClause>? clauses,
    String? status,
    DateTime? sentAt,
    DateTime? signedAt,
    DateTime? expiresAt,
    String? signerName,
    String? signerEmail,
    String? notes,
  }) {
    return Contract(
      id: id,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      quoteId: quoteId ?? this.quoteId,
      title: title ?? this.title,
      type: type ?? this.type,
      clauses: clauses ?? this.clauses,
      status: status ?? this.status,
      createdAt: createdAt,
      sentAt: sentAt ?? this.sentAt,
      signedAt: signedAt ?? this.signedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      signerName: signerName ?? this.signerName,
      signerEmail: signerEmail ?? this.signerEmail,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'clientId': clientId,
        'projectId': projectId,
        'quoteId': quoteId,
        'title': title,
        'type': type,
        'clauses': clauses.map((c) => c.toJson()).toList(),
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'signedAt': signedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'signerName': signerName,
        'signerEmail': signerEmail,
        'notes': notes,
      };

  factory Contract.fromJson(Map<dynamic, dynamic> json) => Contract(
        id: json['id']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        quoteId: json['quoteId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        type: json['type']?.toString() ?? 'SOW',
        clauses: (json['clauses'] as List?)
                ?.map((c) =>
                    ContractClause.fromJson(Map<String, dynamic>.from(c)))
                .toList() ??
            [],
        status: json['status']?.toString() ?? 'draft',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? ''),
        signedAt: DateTime.tryParse(json['signedAt']?.toString() ?? ''),
        expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
        signerName: json['signerName']?.toString() ?? '',
        signerEmail: json['signerEmail']?.toString() ?? '',
        notes: json['notes']?.toString() ?? '',
      );
}

class ContractClause {
  final String title;
  final String body;
  final String category; // standard, custom, signature
  final int order;

  const ContractClause({
    required this.title,
    required this.body,
    this.category = 'standard',
    this.order = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'category': category,
        'order': order,
      };

  factory ContractClause.fromJson(Map<dynamic, dynamic> json) => ContractClause(
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        category: json['category']?.toString() ?? 'standard',
        order: (json['order'] as num?)?.toInt() ?? 0,
      );
}
