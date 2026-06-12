import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,
    required String email,
    required String fullName,
    required String role,
    String? institution,
    String? bio,
    List<String>? interests,
    String? avatar,
    @Default(true) bool isActive,
    @Default(false) bool emailVerified,
    DateTime? lastLogin,
    List<dynamic>? bookmarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
