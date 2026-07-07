import 'package:json_annotation/json_annotation.dart';

/// Converter to handle Firestore [Timestamp] and [DateTime] conversion.
/// It supports:
/// - Firestore [Timestamp] (via .toDate() method)
/// - [int] (milliseconds since epoch)
/// - [String] (ISO 8601)
class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json == null) return DateTime.now();

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    // To avoid direct dependency on cloud_firestore in models,
    // we use a dynamic check for the .toDate() method.
    try {
      return json.toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(json.toString());
      } catch (_) {
        return DateTime.now();
      }
    }
  }

  @override
  dynamic toJson(DateTime object) {
    return object.toIso8601String();
  }
}

class NullableTimestampConverter implements JsonConverter<DateTime?, dynamic> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json);
    }

    try {
      return json.toDate() as DateTime;
    } catch (_) {
      try {
        return DateTime.parse(json.toString());
      } catch (_) {
        return null;
      }
    }
  }

  @override
  dynamic toJson(DateTime? object) {
    if (object == null) return null;
    return object.toIso8601String();
  }
}
