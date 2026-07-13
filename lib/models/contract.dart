
import 'quote.dart';

class Contract {
  final String id;
  final String leadId;
  final String quoteId;
  final List<ContractClause> clauses;
  final String status;
  final DateTime createdAt;

  const Contract({
    required this.id, required this.leadId, required this.quoteId,
    this.clauses = const [], this.status = 'Draft',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'leadId': leadId, 'quoteId': quoteId,
    'clauses': clauses.map((c) => c.toJson()).toList(),
    'status': status, 'createdAt': createdAt.toIso8601String(),
  };

  factory Contract.fromJson(Map<dynamic, dynamic> json) => Contract(
    id: json['id']?.toString() ?? '',
    leadId: json['leadId']?.toString() ?? '',
    quoteId: json['quoteId']?.toString() ?? '',
    clauses: (json['clauses'] as List?)
        ?.map((c) => ContractClause.fromJson(Map<String, dynamic>.from(c))).toList() ?? [],
    status: json['status']?.toString() ?? 'Draft',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
  );
}

class ContractClause {
  final String title;
  final String body;
  final String category; // 'standard', 'conditional', 'disclaimer'
  final String trigger; // what rule triggered this clause

  const ContractClause({
    required this.title, required this.body,
    this.category = 'standard', this.trigger = '',
  });

  Map<String, dynamic> toJson() => {
    'title': title, 'body': body, 'category': category, 'trigger': trigger,
  };

  factory ContractClause.fromJson(Map<dynamic, dynamic> json) => ContractClause(
    title: json['title']?.toString() ?? '',
    body: json['body']?.toString() ?? '',
    category: json['category']?.toString() ?? 'standard',
    trigger: json['trigger']?.toString() ?? '',
  );
}
