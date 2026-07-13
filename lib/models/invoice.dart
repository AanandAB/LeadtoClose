
class Invoice {
  final String id;
  final String leadId;
  final String quoteId;
  final String number;
  final List<InvoiceLineItem> lineItems;
  final double subtotal;
  final double gstAmount;
  final double total;
  final String gstTreatment;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final String sacCode;
  final String currency;
  final String status;
  final DateTime createdAt;
  final DateTime dueDate;
  final double expectedTdsAmount;
  final String firaReference;

  Invoice({
    required this.id, required this.leadId, required this.quoteId,
    this.number = '', this.lineItems = const [],
    this.subtotal = 0, this.gstAmount = 0, this.total = 0,
    this.gstTreatment = 'No GST', this.cgstRate = 0,
    this.sgstRate = 0, this.igstRate = 0,
    this.sacCode = '998314', this.currency = 'INR',
    this.status = 'Draft', required this.createdAt,
    DateTime? dueDate, this.expectedTdsAmount = 0.0,
    this.firaReference = '',
  }) : dueDate = dueDate ?? createdAt.add(Duration(days: 30));

  Invoice copyWith({
    String? status, String? firaReference,
  }) {
    return Invoice(
      id: id, leadId: leadId, quoteId: quoteId, number: number,
      lineItems: lineItems, subtotal: subtotal, gstAmount: gstAmount,
      total: total, gstTreatment: gstTreatment, cgstRate: cgstRate,
      sgstRate: sgstRate, igstRate: igstRate, sacCode: sacCode,
      currency: currency, status: status ?? this.status,
      createdAt: createdAt, dueDate: dueDate,
      expectedTdsAmount: expectedTdsAmount,
      firaReference: firaReference ?? this.firaReference,
    );
  }

  bool get isOverdue => status == 'Sent' && DateTime.now().isAfter(dueDate);
  int get daysOverdue => DateTime.now().difference(dueDate).inDays;
  int get daysUntilLimitation => 3 * 365 - DateTime.now().difference(dueDate).inDays;

  Map<String, dynamic> toJson() => {
    'id': id, 'leadId': leadId, 'quoteId': quoteId, 'number': number,
    'lineItems': lineItems.map((i) => i.toJson()).toList(),
    'subtotal': subtotal, 'gstAmount': gstAmount, 'total': total,
    'gstTreatment': gstTreatment, 'cgstRate': cgstRate,
    'sgstRate': sgstRate, 'igstRate': igstRate, 'sacCode': sacCode,
    'currency': currency, 'status': status,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'expectedTdsAmount': expectedTdsAmount,
    'firaReference': firaReference,
  };

  factory Invoice.fromJson(Map<dynamic, dynamic> json) => Invoice(
    id: json['id']?.toString() ?? '',
    leadId: json['leadId']?.toString() ?? '',
    quoteId: json['quoteId']?.toString() ?? '',
    number: json['number']?.toString() ?? '',
    lineItems: (json['lineItems'] as List?)
        ?.map((i) => InvoiceLineItem.fromJson(Map<String, dynamic>.from(i))).toList() ?? [],
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    gstAmount: (json['gstAmount'] as num?)?.toDouble() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    gstTreatment: json['gstTreatment']?.toString() ?? 'No GST',
    cgstRate: (json['cgstRate'] as num?)?.toDouble() ?? 0,
    sgstRate: (json['sgstRate'] as num?)?.toDouble() ?? 0,
    igstRate: (json['igstRate'] as num?)?.toDouble() ?? 0,
    sacCode: json['sacCode']?.toString() ?? '998314',
    currency: json['currency']?.toString() ?? 'INR',
    status: json['status']?.toString() ?? 'Draft',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
    expectedTdsAmount: (json['expectedTdsAmount'] as num?)?.toDouble() ?? 0,
    firaReference: json['firaReference']?.toString() ?? '',
  );
}

class InvoiceLineItem {
  final String description;
  final double amount;
  final String category;

  const InvoiceLineItem({required this.description, required this.amount, this.category = 'Service'});

  Map<String, dynamic> toJson() => {'description': description, 'amount': amount, 'category': category};

  factory InvoiceLineItem.fromJson(Map<dynamic, dynamic> json) => InvoiceLineItem(
    description: json['description']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    category: json['category']?.toString() ?? 'Service',
  );
}
