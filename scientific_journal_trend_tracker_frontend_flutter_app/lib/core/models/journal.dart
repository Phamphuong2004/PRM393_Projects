import 'package:freezed_annotation/freezed_annotation.dart';

part 'journal.freezed.dart';
part 'journal.g.dart';

@freezed
abstract class Journal with _$Journal {
  const factory Journal({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? issn,
    String? publisher,
    double? impactFactor,
    int? hIndex,
    @Default(0) int paperCount,
    String? fieldDomain,
    @Default(false) bool isTracked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Journal;

  factory Journal.fromJson(Map<String, dynamic> json) => _$JournalFromJson(json);
}
