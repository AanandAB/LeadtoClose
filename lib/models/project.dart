enum ProjectStatus { planning, active, onHold, completed, cancelled }

enum ProjectView { kanban, list, timeline, calendar }

class Project {
  final String id;
  final String name;
  final String clientId;
  final String description;
  final ProjectStatus status;
  final String priority; // low, medium, high, urgent
  final double budget;
  final double spent;
  final DateTime? startDate;
  final DateTime? dueDate;
  final DateTime? completedDate;
  final List<String> tags;
  final String templateId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    required this.clientId,
    this.description = '',
    this.status = ProjectStatus.planning,
    this.priority = 'medium',
    this.budget = 0,
    this.spent = 0,
    this.startDate,
    this.dueDate,
    this.completedDate,
    this.tags = const [],
    this.templateId = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get budgetRemaining => budget - spent;
  double get budgetPercentage => budget > 0 ? (spent / budget * 100) : 0;
  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      status != ProjectStatus.completed;

  Project copyWith({
    String? name,
    String? clientId,
    String? description,
    ProjectStatus? status,
    String? priority,
    double? budget,
    double? spent,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      clientId: clientId ?? this.clientId,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      tags: tags ?? this.tags,
      templateId: templateId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'clientId': clientId,
        'description': description,
        'status': status.name,
        'priority': priority,
        'budget': budget,
        'spent': spent,
        'startDate': startDate?.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'completedDate': completedDate?.toIso8601String(),
        'tags': tags,
        'templateId': templateId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Project.fromJson(Map<dynamic, dynamic> json) => Project(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        status: ProjectStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ProjectStatus.planning,
        ),
        priority: json['priority']?.toString() ?? 'medium',
        budget: (json['budget'] as num?)?.toDouble() ?? 0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        startDate: DateTime.tryParse(json['startDate']?.toString() ?? ''),
        dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
        completedDate:
            DateTime.tryParse(json['completedDate']?.toString() ?? ''),
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        templateId: json['templateId']?.toString() ?? '',
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}

class ProjectTemplate {
  final String id;
  final String name;
  final String description;
  final List<TaskTemplate> tasks;
  final List<MilestoneTemplate> milestones;

  const ProjectTemplate({
    required this.id,
    required this.name,
    this.description = '',
    this.tasks = const [],
    this.milestones = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tasks': tasks.map((t) => t.toJson()).toList(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
      };

  factory ProjectTemplate.fromJson(Map<dynamic, dynamic> json) =>
      ProjectTemplate(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        tasks: (json['tasks'] as List?)
                ?.map((t) =>
                    TaskTemplate.fromJson(Map<String, dynamic>.from(t)))
                .toList() ??
            [],
        milestones: (json['milestones'] as List?)
                ?.map((m) => MilestoneTemplate.fromJson(
                    Map<String, dynamic>.from(m)))
                .toList() ??
            [],
      );
}

class TaskTemplate {
  final String title;
  final String description;
  final String listName;
  final int estimatedHours;

  const TaskTemplate({
    required this.title,
    this.description = '',
    this.listName = 'To Do',
    this.estimatedHours = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'listName': listName,
        'estimatedHours': estimatedHours,
      };

  factory TaskTemplate.fromJson(Map<dynamic, dynamic> json) => TaskTemplate(
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        listName: json['listName']?.toString() ?? 'To Do',
        estimatedHours: (json['estimatedHours'] as num?)?.toInt() ?? 0,
      );
}

class MilestoneTemplate {
  final String title;
  final double percentage;
  final int taskCount;

  const MilestoneTemplate({
    required this.title,
    this.percentage = 0,
    this.taskCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'percentage': percentage,
        'taskCount': taskCount,
      };

  factory MilestoneTemplate.fromJson(Map<dynamic, dynamic> json) =>
      MilestoneTemplate(
        title: json['title']?.toString() ?? '',
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
        taskCount: (json['taskCount'] as num?)?.toInt() ?? 0,
      );
}

class Milestone {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final double percentage;
  final bool isApproved;
  final DateTime? dueDate;
  final DateTime createdAt;

  Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.percentage = 0,
    this.isApproved = false,
    this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Milestone copyWith({
    String? title,
    String? description,
    double? percentage,
    bool? isApproved,
    DateTime? dueDate,
  }) {
    return Milestone(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      percentage: percentage ?? this.percentage,
      isApproved: isApproved ?? this.isApproved,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'percentage': percentage,
        'isApproved': isApproved,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Milestone.fromJson(Map<dynamic, dynamic> json) => Milestone(
        id: json['id']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
        isApproved: json['isApproved'] == true,
        dueDate: DateTime.tryParse(json['dueDate']?.toString() ?? ''),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
