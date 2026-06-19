class Author {
  final String id;
  final String fullName;
  final String? externalAuthorId;
  final String? affiliation;
  final String? orcid;
  final String? operalId;
  final int workCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Author({
    required this.id,
    required this.fullName,
    this.externalAuthorId,
    this.affiliation,
    this.orcid,
    this.operalId,
    this.workCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      externalAuthorId: json['externalAuthorId'] as String?,
      affiliation: json['affiliation'] as String?,
      orcid: json['orcid'] as String?,
      operalId: json['operalId'] as String?,
      workCount: json['workCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'externalAuthorId': externalAuthorId,
      'affiliation': affiliation,
      'orcid': orcid,
      'operalId': operalId,
      'workCount': workCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
