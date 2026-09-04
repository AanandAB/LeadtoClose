enum InvoiceStatus { draft, sent, viewed, partial, paid, overdue, cancelled }

class Invoice {
  final String id;
  final String number;
  final String clientId;
  final String projectId;
  final String quoteId;
  final List<InvoiceLineItem> lineItems;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final double amountPaid;
  final String currency;
  final String status;
  final String notes;
  final String paymentTerms;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? paidAt;
  final List<InvoicePayment> payments;

  Invoice({
    required this.id,
    required this.number,
    this.clientId = '',
    this.projectId = '',
    this.quoteId = '',
    this.lineItems = const [],
    this.subtotal = 0,
    this.taxRate = 0,
    this.taxAmount = 0,
    this.discount = 0,
    this.total = 0,
    this.amountPaid = 0,
    this.currency = 'USD',
    this.status = 'active',
    this.notes = '',
    this.paymentTerms = 'Net 30',
    DateTime? createdAt,
    DateTime? dueDate,
    this.paidAt,
    this.payments = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        dueDate = dueDate ?? DateTime.now().add(const Duration(days: 30));

  double get balanceDue => total - amountPaid;
  bool get isOverdue =>
      status != 'paid' &&
      status != 'cancelled' &&
      DateTime.now().isAfter(dueDate);
  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;

  InvoiceStatus get invoiceStatus => InvoiceStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => InvoiceStatus.draft,
      );

  Invoice copyWith({
    String? number,
    String? clientId,
    String? projectId,
    String? quoteId,
    List<InvoiceLineItem>? lineItems,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    double? total,
    double? amountPaid,
    String? currency,
    String? status,
    String? notes,
    String? paymentTerms,
    DateTime? dueDate,
    DateTime? paidAt,
    List<InvoicePayment>? payments,
  }) {
    return Invoice(
      id: id,
      number: number ?? this.number,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      quoteId: quoteId ?? this.quoteId,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      amountPaid: amountPaid ?? this.amountPaid,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      createdAt: createdAt,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      payments: payments ?? this.payments,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'clientId': clientId,
        'projectId': projectId,
        'quoteId': quoteId,
        'lineItems': lineItems.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'taxRate': taxRate,
        'taxAmount': taxAmount,
        'discount': discount,
        'total': total,
        'amountPaid': amountPaid,
        'currency': currency,
        'status': status,
        'notes': notes,
        'paymentTerms': paymentTerms,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'paidAt': paidAt?.toIso8601String(),
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory Invoice.fromJson(Map<dynamic, dynamic> json) => Invoice(
        id: json['id']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        quoteId: json['quoteId']?.toString() ?? '',
        lineItems: (json['lineItems'] as List?)
                ?.map((i) =>
                    InvoiceLineItem.fromJson(Map<String, dynamic>.from(i)))
                .toList() ??
            [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0,
        taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0,
        discount: (json['discount'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0,
        currency: json['currency']?.toString() ?? 'USD',
        status: json['status']?.toString() ?? 'active',
        notes: json['notes']?.toString() ?? '',
        paymentTerms: json['paymentTerms']?.toString() ?? 'Net 30',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        paidAt: DateTime.tryParse(json['paidAt']?.toString() ?? ''),
        payments: (json['payments'] as List?)
                ?.map((p) =>
                    InvoicePayment.fromJson(Map<String, dynamic>.from(p)))
                .toList() ??
            [],
      );
}

class InvoiceLineItem {
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final String unit; // hour, item, fixed

  InvoiceLineItem({
    required this.description,
    this.quantity = 1,
    this.rate = 0,
    this.amount = 0,
    this.unit = 'item',
  });

  double get calculatedAmount => quantity * rate;

  InvoiceLineItem copyWith({
    String? description,
    double? quantity,
    double? rate,
    double? amount,
    String? unit,
  }) {
    return InvoiceLineItem(
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'unit': unit,
      };

  factory InvoiceLineItem.fromJson(Map<dynamic, dynamic> json) =>
      InvoiceLineItem(
        description: json['description']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
        rate: (json['rate'] as num?)?.toDouble() ?? 0,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        unit: json['unit']?.toString() ?? 'item',
      );
}

class InvoicePayment {
  final String id;
  final double amount;
  final DateTime date;
  final String method;
  final String reference;

  InvoicePayment({
    required this.id,
    required this.amount,
    DateTime? date,
    this.method = '',
    this.reference = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'method': method,
        'reference': reference,
      };

  factory InvoicePayment.fromJson(Map<dynamic, dynamic> json) =>
      InvoicePayment(
        id: json['id']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        method: json['method']?.toString() ?? '',
        reference: json['reference']?.toString() ?? '',
      );
}
