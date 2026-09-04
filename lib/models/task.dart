enum TaskStatus { todo, inProgress, review, done }

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final String priority; // low, medium, high, urgent
  final DateTime? dueDate;
  final String assigneeId;
  final List<String> tags;
  final double estimatedHours;
  final bool isClientVisible;
  final String parentId; // for subtasks
  final List<String> dependencies; // task IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = TaskStatus.todo,
    this.priority = 'medium',
    this.dueDate,
    this.assigneeId = '',
    this.tags = const [],
    this.estimatedHours = 0,
    this.isClientVisible = true,
    this.parentId = '',
    this.dependencies = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      status != TaskStatus.done;

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    String? priority,
    DateTime? dueDate,
    String? assigneeId,
    List<String>? tags,
    double? estimatedHours,
    bool? isClientVisible,
    String? parentId,
    List<String>? dependencies,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      assigneeId: assigneeId ?? this.assigneeId,
      tags: tags ?? this.tags,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      isClientVisible: isClientVisible ?? this.isClientVisible,
      parentId: parentId ?? this.parentId,
      dependencies: dependencies ?? this.dependencies,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'status': status.name,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'assigneeId': assigneeId,
        'tags': tags,
        'estimatedHours': estimatedHours,
        'isClientVisible': isClientVisible,
        'parentId': parentId,
        'dependencies': dependencies,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Task.fromJson(Map<dynamic, dynamic> json) => Task(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        status: TaskStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TaskStatus.todo,
        ),
        priority: json['priority']?.toString() ?? 'medium',
        dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
        assigneeId: json['assigneeId']?.toString() ?? '',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0,
        isClientVisible: json['isClientVisible'] != false,
        parentId: json['parentId']?.toString() ?? '',
        dependencies:
            (json['dependencies'] as List?)?.map((e) => e.toString()).toList() ??
                [],
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
