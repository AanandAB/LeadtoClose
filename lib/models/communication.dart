enum CommunicationType { email, call, meeting, note, sms }

class Communication {
  final String id;
  final String clientId;
  final String leadId;
  final String projectId;
  final CommunicationType type;
  final String direction; // inbound, outbound
  final String subject;
  final String body;
  final String contactName;
  final String contactEmail;
  final bool isInternal;
  final DateTime createdAt;

  Communication({
    required this.id,
    this.clientId = '',
    this.leadId = '',
    this.projectId = '',
    required this.type,
    this.direction = 'outbound',
    this.subject = '',
    this.body = '',
    this.contactName = '',
    this.contactEmail = '',
    this.isInternal = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Communication copyWith({
    String? subject,
    String? body,
    bool? isInternal,
  }) {
    return Communication(
      id: id,
      clientId: clientId,
      leadId: leadId,
      projectId: projectId,
      type: type,
      direction: direction,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      contactName: contactName,
      contactEmail: contactEmail,
      isInternal: isInternal ?? this.isInternal,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'leadId': leadId,
        'projectId': projectId,
        'type': type.name,
        'direction': direction,
        'subject': subject,
        'body': body,
        'contactName': contactName,
        'contactEmail': contactEmail,
        'isInternal': isInternal,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Communication.fromJson(Map<dynamic, dynamic> json) => Communication(
        id: json['id']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        leadId: json['leadId']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        type: CommunicationType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => CommunicationType.note,
        ),
        direction: json['direction']?.toString() ?? 'outbound',
        subject: json['subject']?.toString() ?? '',
        body: json['body']?.toString() ?? '',
        contactName: json['contactName']?.toString() ?? '',
        contactEmail: json['contactEmail']?.toString() ?? '',
        isInternal: json['isInternal'] == true,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
