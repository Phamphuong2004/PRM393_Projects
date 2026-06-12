import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
abstract class Topic with _$Topic {
  const factory Topic({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? description,
    @Default(0) int paperCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}
