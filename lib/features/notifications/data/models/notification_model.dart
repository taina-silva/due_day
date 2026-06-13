import 'package:due_day/core/utils/converters/timestamp_converter.dart';
import 'package:due_day/features/notifications/domain/entities/notification_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

@freezed
class NotificationModel with _$NotificationModel {
  const NotificationModel._();

  const factory NotificationModel({
    required String id,
    required String userId,
    required String title,
    required String description,
    @TimestampConverter() required DateTime timestamp,
    required bool read,
    required bool isUrgent,
    required String type,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      timestamp: entity.timestamp,
      read: entity.read,
      isUrgent: entity.isUrgent,
      type: entity.type.name,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      timestamp: timestamp,
      read: read,
      isUrgent: isUrgent,
      type: NotificationType.fromString(type),
    );
  }
}
