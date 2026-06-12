import 'package:freezed_annotation/freezed_annotation.dart';


part 'paper.freezed.dart';
part 'paper.g.dart';

@freezed
abstract class PaperAuthor with _$PaperAuthor {
  const factory PaperAuthor({
    @JsonKey(name: '_id') String? id,
    required String fullName,
    String? externalAuthorId,
    String? affiliation,
  }) = _PaperAuthor;

  factory PaperAuthor.fromJson(Map<String, dynamic> json) => _$PaperAuthorFromJson(json);
}

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Paper with _$Paper {
  const factory Paper({
    @JsonKey(name: '_id') required String id,
    required String title,
    String? abstract,
    String? doi,
    int? publicationYear,
    @JsonKey(name: 'citationCount') @Default(0) int citationCount,
    @JsonKey(name: 'externalId_openalexId') String? externalIdOpenalexId,
    List<PaperAuthor>? authors,
    dynamic journalId,
    List<dynamic>? keywords,
    List<dynamic>? topics,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Paper;

  factory Paper.fromJson(Map<String, dynamic> json) => _$PaperFromJson(json);
}
