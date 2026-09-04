class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final String description;
  final double hours;
  final DateTime date;
  final bool isBillable;
  final String rate; // hourly rate at time of entry
  final DateTime createdAt;

  TimeEntry({
    required this.id,
    required this.projectId,
    this.taskId = '',
    this.description = '',
    this.hours = 0,
    DateTime? date,
    this.isBillable = true,
    this.rate = '',
    DateTime? createdAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  double get amount {
    final rateValue = double.tryParse(rate) ?? 0;
    return hours * rateValue;
  }

  TimeEntry copyWith({
    String? description,
    double? hours,
    DateTime? date,
    bool? isBillable,
    String? rate,
  }) {
    return TimeEntry(
      id: id,
      projectId: projectId,
      taskId: taskId,
      description: description ?? this.description,
      hours: hours ?? this.hours,
      date: date ?? this.date,
      isBillable: isBillable ?? this.isBillable,
      rate: rate ?? this.rate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'taskId': taskId,
        'description': description,
        'hours': hours,
        'date': date.toIso8601String(),
        'isBillable': isBillable,
        'rate': rate,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TimeEntry.fromJson(Map<dynamic, dynamic> json) => TimeEntry(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        taskId: json['taskId']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        hours: (json['hours'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
        isBillable: json['isBillable'] != false,
        rate: json['rate']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
