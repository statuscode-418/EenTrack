import 'package:eentrack/models/export_fields.dart';

import 'model.dart';

class AttendedMeetings implements DataModel {
  final String id;
  final String host;
  final String title;
  final String description;
  final DateTime date;
  final double latitude;
  final double longitude;

  AttendedMeetings({
    required this.id,
    required this.host,
    required this.title,
    required this.description,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  AttendedMeetings copyWith({
    String? id,
    String? host,
    String? title,
    String? description,
    DateTime? date,
    double? latitude,
    double? longitude,
  }) {
    return AttendedMeetings(
        id: id ?? this.id,
        host: host ?? this.host,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'host': host,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AttendedMeetings.fromMap(Map<String, dynamic> map) {
    return AttendedMeetings(
      id: map['id'],
      host: map['host'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  @override
  Map<String, dynamic> exportData({List<ExportField> fields = const []}) {
    throw UnimplementedError();
  }
}
