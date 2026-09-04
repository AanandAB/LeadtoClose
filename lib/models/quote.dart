enum QuoteStatus { draft, sent, viewed, accepted, rejected, expired }

class Quote {
  final String id;
  final String number;
  final String clientId;
  final String leadId;
  final String projectId;
  final String title;
  final String description;
  final List<QuoteLineItem> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final String currency;
  final String status;
  final String validUntil;
  final String notes;
  final String terms;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? acceptedAt;
  final int viewCount;

  Quote({
    required this.id,
    required this.number,
    this.clientId = '',
    this.leadId = '',
    this.projectId = '',
    this.title = '',
    this.description = '',
    this.lineItems = const [],
    this.subtotal = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.discount = 0,
    this.total = 0,
    this.currency = 'USD',
    this.status = 'draft',
    this.validUntil = '30 days',
    this.notes = '',
    this.terms = '',
    DateTime? createdAt,
    this.sentAt,
    this.acceptedAt,
    this.viewCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  QuoteStatus get quoteStatus => QuoteStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => QuoteStatus.draft,
      );

  Quote copyWith({
    String? number,
    String? clientId,
    String? leadId,
    String? projectId,
    String? title,
    String? description,
    List<QuoteLineItem>? lineItems,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    double? total,
    String? currency,
    String? status,
    String? validUntil,
    String? notes,
    String? terms,
    DateTime? sentAt,
    DateTime? acceptedAt,
    int? viewCount,
  }) {
    return Quote(
      id: id,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      leadId: leadId ?? this.leadId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      createdAt: createdAt,
      sentAt: sentAt ?? this.sentAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'clientId': clientId,
        'leadId': leadId,
        'projectId': projectId,
        'title': title,
        'description': description,
        'lineItems': lineItems.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'taxRate': taxRate,
        'taxAmount': taxAmount,
        'discount': discount,
        'total': total,
        'currency': currency,
        'status': status,
        'validUntil': validUntil,
        'notes': notes,
        'terms': terms,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'acceptedAt': acceptedAt?.toIso8601String(),
        'viewCount': viewCount,
      };

  factory Quote.fromJson(Map<dynamic, dynamic> json) => Quote(
        id: json['id']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        leadId: json['leadId']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        lineItems: (json['lineItems'] as List?)
                ?.map((i) =>
                    QuoteLineItem.fromJson(Map<String, dynamic>.from(i)))
                .toList() ??
            [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'USD',
        status: json['status']?.toString() ?? 'draft',
        validUntil: json['validUntil']?.toString() ?? '30 days',
        notes: json['notes']?.toString() ?? '',
        terms: json['terms']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        sentAt: DateTime.tryParse(json['sentAt']?.toString() ?? ''),
        acceptedAt: DateTime.tryParse(json['acceptedAt']?.toString() ?? ''),
        viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      );
}

class QuoteLineItem {
  final String? id;
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final String unit;
  final bool isOptional;

  const QuoteLineItem({
    this.id,
    required this.description,
    this.quantity = 1,
    this.rate = 0,
    this.amount = 0,
    this.unit = 'item',
    this.isOptional = false,
  });

  double get calculatedAmount => quantity * rate;

  QuoteLineItem copyWith({
    String? description,
    double? quantity,
    double? rate,
    double? amount,
    String? unit,
    bool? isOptional,
  }) {
    return QuoteLineItem(
      id: id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'unit': unit,
        'isOptional': isOptional,
      };

  factory QuoteLineItem.fromJson(Map<dynamic, dynamic> json) => QuoteLineItem(
        id: json['id']?.toString(),
        description: json['description']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        unit: json['unit']?.toString() ?? 'item',
        isOptional: json['isOptional'] == true,
      );
}
