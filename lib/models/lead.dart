
import 'project_profile.dart';

class Lead {
  final String id;
  final String name;
  final String company;
  final String contact;
  final String source;
  final String stage;
  final DateTime createdAt;
  final DateTime lastActivity;
  final ProjectProfile? projectProfile;
  final List<LeadNote> notes;

  const Lead({
    required this.id, required this.name, this.company = '',
    this.contact = '', this.source = 'Direct',
    this.stage = 'New Lead', required this.createdAt,
    DateTime? lastActivity, this.projectProfile, this.notes = const [],
  }) : lastActivity = lastActivity ?? createdAt;

  Lead copyWith({
    String? id, String? name, String? company, String? contact,
    String? source, String? stage, DateTime? createdAt,
    DateTime? lastActivity, ProjectProfile? projectProfile,
    List<LeadNote>? notes,
  }) {
    return Lead(
      id: id ?? this.id, name: name ?? this.name,
      company: company ?? this.company, contact: contact ?? this.contact,
      source: source ?? this.source, stage: stage ?? this.stage,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      projectProfile: projectProfile ?? this.projectProfile,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'company': company, 'contact': contact,
    'source': source, 'stage': stage,
    'createdAt': createdAt.toIso8601String(),
    'lastActivity': lastActivity.toIso8601String(),
    'projectProfile': projectProfile?.toJson(),
    'notes': notes.map((n) => n.toJson()).toList(),
  };

  factory Lead.fromJson(Map<dynamic, dynamic> json) => Lead(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    company: json['company']?.toString() ?? '',
    contact: json['contact']?.toString() ?? '',
    source: json['source']?.toString() ?? 'Direct',
    stage: json['stage']?.toString() ?? 'New Lead',
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    lastActivity: DateTime.tryParse(json['lastActivity']?.toString() ?? ''),
    projectProfile: json['projectProfile'] != null
        ? ProjectProfile.fromJson(Map<String, dynamic>.from(json['projectProfile']))
        : null,
    notes: (json['notes'] as List?)
        ?.map((n) => LeadNote.fromJson(Map<String, dynamic>.from(n))).toList() ?? [],
  );
}

class LeadNote {
  final String text;
  final DateTime timestamp;

  const LeadNote({required this.text, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'text': text, 'timestamp': timestamp.toIso8601String(),
  };

  factory LeadNote.fromJson(Map<dynamic, dynamic> json) => LeadNote(
    text: json['text']?.toString() ?? '',
    timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
  );
}
