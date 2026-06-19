class SyncLog {
  final String id;
  final dynamic apiSource; // Can be a String (ID) or Map (populated)
  final String? seedKeyword;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int papersAdded;
  final int papersSkipped;
  final int papersUpdated;
  final String status; // running, success, failed
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SyncLog({
    required this.id,
    required this.apiSource,
    this.seedKeyword,
    required this.startedAt,
    this.finishedAt,
    this.papersAdded = 0,
    this.papersSkipped = 0,
    this.papersUpdated = 0,
    this.status = 'running',
    this.errorMessage,
    this.createdAt,
    this.updatedAt,
  });

  String get sourceName {
    if (apiSource is Map) {
      return apiSource['name'] as String? ?? 'Unknown';
    }
    return 'Source ID: $apiSource';
  }

  String get sourceBaseUrl {
    if (apiSource is Map) {
      return apiSource['baseUrl'] as String? ?? '';
    }
    return '';
  }

  factory SyncLog.fromJson(Map<String, dynamic> json) {
    return SyncLog(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      apiSource: json['apiSource'],
      seedKeyword: json['seedKeyword'] as String?,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : DateTime.now(),
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt'] as String) : null,
      papersAdded: json['papersAdded'] as int? ?? 0,
      papersSkipped: json['papersSkipped'] as int? ?? 0,
      papersUpdated: json['papersUpdated'] as int? ?? 0,
      status: json['status'] as String? ?? 'running',
      errorMessage: json['errorMessage'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'apiSource': apiSource,
      'seedKeyword': seedKeyword,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'papersAdded': papersAdded,
      'papersSkipped': papersSkipped,
      'papersUpdated': papersUpdated,
      'status': status,
      'errorMessage': errorMessage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
