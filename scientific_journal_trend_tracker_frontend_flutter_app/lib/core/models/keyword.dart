import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyword.freezed.dart';
part 'keyword.g.dart';

@freezed
abstract class Keyword with _$Keyword {
  const factory Keyword({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? normalizedText,
    @Default(0) int workCount,
    @Default(0) int paperCount,
    @Default(0) int citationCount,
    @Default(0.0) double trendScore,
    @Default(0.0) double growthRate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Keyword;

  factory Keyword.fromJson(Map<String, dynamic> json) => _$KeywordFromJson(json);
}
