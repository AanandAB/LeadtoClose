enum LeadStage { newLead, contacted, qualified, proposalSent, negotiation, won, lost }

class Lead {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String company;
  final String source;
  final LeadStage stage;
  final String score; // hot, warm, cold
  final String lostReason;
  final double estimatedBudget;
  final String assignedTo;
  final List<String> tags;
  final List<LeadNote> notes;
  final List<LeadActivity> activities;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastContactedAt;
  final DateTime? followUpDate;

  Lead({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.company = '',
    this.source = 'Direct',
    this.stage = LeadStage.newLead,
    this.score = 'warm',
    this.lostReason = '',
    this.estimatedBudget = 0,
    this.assignedTo = '',
    this.tags = const [],
    this.notes = const [],
    this.activities = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastContactedAt,
    this.followUpDate,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        lastContactedAt = lastContactedAt ?? createdAt ?? DateTime.now();

  bool get isOverdue =>
      followUpDate != null && DateTime.now().isAfter(followUpDate!);

  String get stageLabel {
    switch (stage) {
      case LeadStage.newLead:
        return 'New Lead';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposalSent:
        return 'Proposal Sent';
      case LeadStage.negotiation:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  Lead copyWith({
    String? name,
    String? email,
    String? phone,
    String? company,
    String? source,
    LeadStage? stage,
    String? score,
    String? lostReason,
    double? estimatedBudget,
    String? assignedTo,
    List<String>? tags,
    List<LeadNote>? notes,
    List<LeadActivity>? activities,
    DateTime? updatedAt,
    DateTime? lastContactedAt,
    DateTime? followUpDate,
  }) {
    return Lead(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      source: source ?? this.source,
      stage: stage ?? this.stage,
      score: score ?? this.score,
      lostReason: lostReason ?? this.lostReason,
      estimatedBudget: estimatedBudget ?? this.estimatedBudget,
      assignedTo: assignedTo ?? this.assignedTo,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      followUpDate: followUpDate ?? this.followUpDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'company': company,
        'source': source,
        'stage': stage.name,
        'score': score,
        'lostReason': lostReason,
        'estimatedBudget': estimatedBudget,
        'assignedTo': assignedTo,
        'tags': tags,
        'notes': notes.map((n) => n.toJson()).toList(),
        'activities': activities.map((a) => a.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'lastContactedAt': lastContactedAt.toIso8601String(),
        'followUpDate': followUpDate?.toIso8601String(),
      };

  factory Lead.fromJson(Map<dynamic, dynamic> json) => Lead(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        company: json['company']?.toString() ?? '',
        source: json['source']?.toString() ?? 'Direct',
        stage: LeadStage.values.firstWhere(
          (e) => e.name == json['stage'],
          orElse: () => LeadStage.newLead,
        ),
        score: json['score']?.toString() ?? 'warm',
        lostReason: json['lostReason']?.toString() ?? '',
        estimatedBudget: (json['estimatedBudget'] as num?)?.toDouble() ?? 0,
        assignedTo: json['assignedTo']?.toString() ?? '',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
        notes: (json['notes'] as List?)
                ?.map((n) => LeadNote.fromJson(Map<String, dynamic>.from(n)))
                .toList() ??
            [],
        activities: (json['activities'] as List?)
                ?.map(
                    (a) => LeadActivity.fromJson(Map<String, dynamic>.from(a)))
                .toList() ??
            [],
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        lastContactedAt:
            DateTime.tryParse(json['lastContactedAt']?.toString() ?? '') ??
                DateTime.now(),
        followUpDate:
            DateTime.tryParse(json['followUpDate']?.toString() ?? ''),
      );
}

class LeadNote {
  final String text;
  final DateTime timestamp;

  const LeadNote({required this.text, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LeadNote.fromJson(Map<dynamic, dynamic> json) => LeadNote(
        text: json['text']?.toString() ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      );
}

class LeadActivity {
  final String type; // email, call, meeting, note, stage_change
  final String description;
  final DateTime timestamp;

  const LeadActivity({
    required this.type,
    required this.description,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LeadActivity.fromJson(Map<dynamic, dynamic> json) => LeadActivity(
        type: json['type']?.toString() ?? 'note',
        description: json['description']?.toString() ?? '',
        timestamp:
            DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      );
}
