// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['_id'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  role: json['role'] as String,
  institution: json['institution'] as String?,
  bio: json['bio'] as String?,
  interests: (json['interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  avatar: json['avatar'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  emailVerified: json['emailVerified'] as bool? ?? false,
  lastLogin: json['lastLogin'] == null
      ? null
      : DateTime.parse(json['lastLogin'] as String),
  bookmarks: json['bookmarks'] as List<dynamic>?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  '_id': instance.id,
  'email': instance.email,
  'fullName': instance.fullName,
  'role': instance.role,
  'institution': instance.institution,
  'bio': instance.bio,
  'interests': instance.interests,
  'avatar': instance.avatar,
  'isActive': instance.isActive,
  'emailVerified': instance.emailVerified,
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'bookmarks': instance.bookmarks,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
