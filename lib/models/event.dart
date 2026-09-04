enum EventType { meeting, deadline, followUp, call, other }

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final EventType type;
  final DateTime startTime;
  final DateTime endTime;
  final String clientId;
  final String projectId;
  final String leadId;
  final bool isAllDay;
  final String location;
  final List<String> attendees;
  final bool isCompleted;
  final DateTime createdAt;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description = '',
    this.type = EventType.meeting,
    required this.startTime,
    DateTime? endTime,
    this.clientId = '',
    this.projectId = '',
    this.leadId = '',
    this.isAllDay = false,
    this.location = '',
    this.attendees = const [],
    this.isCompleted = false,
    DateTime? createdAt,
  })  : endTime = endTime ?? startTime.add(const Duration(hours: 1)),
        createdAt = createdAt ?? DateTime.now();

  CalendarEvent copyWith({
    String? title,
    String? description,
    EventType? type,
    DateTime? startTime,
    DateTime? endTime,
    String? clientId,
    String? projectId,
    String? leadId,
    bool? isAllDay,
    String? location,
    List<String>? attendees,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      leadId: leadId ?? this.leadId,
      isAllDay: isAllDay ?? this.isAllDay,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'clientId': clientId,
        'projectId': projectId,
        'leadId': leadId,
        'isAllDay': isAllDay,
        'location': location,
        'attendees': attendees,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CalendarEvent.fromJson(Map<dynamic, dynamic> json) => CalendarEvent(
        id: json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        type: EventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => EventType.other,
        ),
        startTime: DateTime.tryParse(json['startTime']?.toString() ?? '') ??
            DateTime.now(),
        endTime: DateTime.tryParse(json['endTime']?.toString() ?? ''),
        clientId: json['clientId']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        leadId: json['leadId']?.toString() ?? '',
        isAllDay: json['isAllDay'] == true,
        location: json['location']?.toString() ?? '',
        attendees:
            (json['attendees'] as List?)?.map((e) => e.toString()).toList() ??
                [],
        isCompleted: json['isCompleted'] == true,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
