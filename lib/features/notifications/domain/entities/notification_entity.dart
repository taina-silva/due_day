import 'package:equatable/equatable.dart';

enum NotificationType {
  dueToday,
  upcomingDue,
  recurringDebited,
  overdue;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.upcomingDue,
    );
  }
}

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool read;
  final bool isUrgent;
  final NotificationType type;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.read,
    required this.isUrgent,
    required this.type,
  });

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? read,
    bool? isUrgent,
    NotificationType? type,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      isUrgent: isUrgent ?? this.isUrgent,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    timestamp,
    read,
    isUrgent,
    type,
  ];
}
