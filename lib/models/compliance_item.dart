
enum ComplianceCategory { build, contract, advisory, invoicing }

class ComplianceItem {
  final String id;
  final String title;
  final String description;
  final ComplianceCategory category;
  final bool isCompleted;

  const ComplianceItem({
    required this.id, required this.title, this.description = '',
    required this.category, this.isCompleted = false,
  });

  String get categoryLabel {
    switch (category) {
      case ComplianceCategory.build: return 'Build';
      case ComplianceCategory.contract: return 'Contract';
      case ComplianceCategory.advisory: return 'Advisory';
      case ComplianceCategory.invoicing: return 'Invoicing';
    }
  }

  ComplianceItem copyWith({bool? isCompleted}) {
    return ComplianceItem(id: id, title: title, description: description,
      category: category, isCompleted: isCompleted ?? this.isCompleted);
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'category': category.name, 'isCompleted': isCompleted,
  };

  factory ComplianceItem.fromJson(Map<dynamic, dynamic> json) => ComplianceItem(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    category: ComplianceCategory.values.firstWhere(
      (e) => e.name == json['category'], orElse: () => ComplianceCategory.build),
    isCompleted: json['isCompleted'] == true,
  );
}
