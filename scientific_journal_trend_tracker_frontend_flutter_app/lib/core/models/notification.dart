import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
abstract class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    @JsonKey(name: '_id') required String id,
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    String? relatedType,
    @Default(false) bool isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
}
