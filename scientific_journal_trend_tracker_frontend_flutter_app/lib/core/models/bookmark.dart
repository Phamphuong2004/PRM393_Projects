import 'package:freezed_annotation/freezed_annotation.dart';
import 'paper.dart';

part 'bookmark.freezed.dart';
part 'bookmark.g.dart';

@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    @JsonKey(name: '_id') required String id,
    required String userId,
    required Paper paperId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);
}
