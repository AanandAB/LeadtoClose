class AppDocument {
  final String id;
  final String name;
  final String projectId;
  final String clientId;
  final String filePath;
  final String mimeType;
  final double sizeBytes;
  final bool isClientVisible;
  final int version;
  final DateTime createdAt;

  AppDocument({
    required this.id,
    required this.name,
    this.projectId = '',
    this.clientId = '',
    this.filePath = '',
    this.mimeType = '',
    this.sizeBytes = 0,
    this.isClientVisible = true,
    this.version = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get sizeDisplay {
    if (sizeBytes < 1024) return '${sizeBytes.toStringAsFixed(0)} B';
    if (sizeBytes < 1024 * 1024)
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get icon {
    if (mimeType.contains('pdf')) return 'pdf';
    if (mimeType.contains('image')) return 'image';
    if (mimeType.contains('video')) return 'video';
    if (mimeType.contains('zip') || mimeType.contains('archive'))
      return 'archive';
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel'))
      return 'spreadsheet';
    if (mimeType.contains('document') || mimeType.contains('word'))
      return 'document';
    return 'file';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'projectId': projectId,
        'clientId': clientId,
        'filePath': filePath,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'isClientVisible': isClientVisible,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppDocument.fromJson(Map<dynamic, dynamic> json) => AppDocument(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        clientId: json['clientId']?.toString() ?? '',
        filePath: json['filePath']?.toString() ?? '',
        mimeType: json['mimeType']?.toString() ?? '',
        sizeBytes: (json['sizeBytes'] as num?)?.toDouble() ?? 0,
        isClientVisible: json['isClientVisible'] != false,
        version: (json['version'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
