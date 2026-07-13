
class Quote {
  final String id;
  final String leadId;
  final int version;
  final List<QuoteLineItem> lineItems;
  final double subtotal;
  final double gstAmount;
  final double total;
  final String gstTreatment;
  final String status;
  final DateTime createdAt;
  final String sacCode;

  const Quote({
    required this.id, required this.leadId, this.version = 1,
    this.lineItems = const [], this.subtotal = 0,
    this.gstAmount = 0, this.total = 0,
    this.gstTreatment = 'No GST', this.status = 'Draft',
    required this.createdAt, this.sacCode = '998314',
  });

  Quote copyWith({
    String? id, int? version, List<QuoteLineItem>? lineItems,
    double? subtotal, double? gstAmount, double? total,
    String? gstTreatment, String? status, String? sacCode,
  }) {
    return Quote(
      id: id ?? this.id, leadId: leadId, version: version ?? this.version,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      gstAmount: gstAmount ?? this.gstAmount,
      total: total ?? this.total,
      gstTreatment: gstTreatment ?? this.gstTreatment,
      status: status ?? this.status,
      createdAt: createdAt, sacCode: sacCode ?? this.sacCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'leadId': leadId, 'version': version,
    'lineItems': lineItems.map((i) => i.toJson()).toList(),
    'subtotal': subtotal, 'gstAmount': gstAmount, 'total': total,
    'gstTreatment': gstTreatment, 'status': status,
    'createdAt': createdAt.toIso8601String(), 'sacCode': sacCode,
  };

  factory Quote.fromJson(Map<dynamic, dynamic> json) => Quote(
    id: json['id']?.toString() ?? '',
    leadId: json['leadId']?.toString() ?? '',
    version: (json['version'] as num?)?.toInt() ?? 1,
    lineItems: (json['lineItems'] as List?)
        ?.map((i) => QuoteLineItem.fromJson(Map<String, dynamic>.from(i))).toList() ?? [],
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    gstTreatment: json['gstTreatment']?.toString() ?? 'No GST',
    status: json['status']?.toString() ?? 'Draft',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    sacCode: json['sacCode']?.toString() ?? '998314',
  );
}

class QuoteLineItem {
  final String description;
  final double amount;
  final String category;

  const QuoteLineItem({required this.description, required this.amount, this.category = 'Build'});

  Map<String, dynamic> toJson() => {
    'description': description, 'amount': amount, 'category': category,
  };

  factory QuoteLineItem.fromJson(Map<dynamic, dynamic> json) => QuoteLineItem(
    description: json['description']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    category: json['category']?.toString() ?? 'Build',
  );
}
