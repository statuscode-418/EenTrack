import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eentrack/models/export_fields.dart';
import 'package:eentrack/models/model.dart';

import 'model_consts.dart' as consts;

class Attendee implements DataModel {
  String uid;
  String name;
  String department;
  String roll;
  String semester;
  String email;
  String github;
  String linkedin;
  DateTime date;
  DateTime? addedOn;
  DateTime? leftOn;
  Map<String, Timestamp> breaks = {};
  double? latitude;
  double? longitude;

  bool get isPresent => addedOn != null;
  bool get isLeft => leftOn != null;

  bool get attendedFullMeeting => isPresent && isLeft;

  Attendee({
    required this.uid,
    required this.name,
    required this.department,
    required this.roll,
    required this.semester,
    required this.email,
    required this.date,
    this.addedOn,
    this.leftOn,
    required this.github,
    required this.linkedin,
    this.latitude,
    this.longitude,
  });

  Attendee.newAttendee({
    required this.uid,
    required this.name,
  })  : department = '',
        roll = '',
        semester = '',
        email = '',
        date = DateTime.now(),
        addedOn = null,
        leftOn = null,
        github = '',
        linkedin = '',
        latitude = null,
        longitude = null;

  factory Attendee.fromMap(Map<String, dynamic> json) {
    return Attendee(
      uid: json[consts.uid],
      name: json[consts.name],
      department: json[consts.department],
      roll: json[consts.roll],
      semester: json[consts.semester],
      email: json[consts.email],
      date: json[consts.date].toDate(),
      addedOn: json[consts.addedOn]?.toDate(),
      leftOn: json[consts.leftOn]?.toDate(),
      github: json[consts.github],
      linkedin: json[consts.linkedin],
      latitude: json[consts.latitude],
      longitude: json[consts.longitude],
    );
  }

  @override
  Map<String, dynamic> toMap() => {
        consts.uid: uid,
        consts.name: name,
        consts.department: department,
        consts.roll: roll,
        consts.semester: semester,
        consts.email: email,
        consts.date: Timestamp.fromDate(date),
        consts.addedOn: addedOn != null ? Timestamp.fromDate(addedOn!) : null,
        consts.leftOn: leftOn != null ? Timestamp.fromDate(leftOn!) : null,
        consts.github: github,
        consts.linkedin: linkedin,
        consts.latitude: latitude,
        consts.longitude: longitude,
      };

  String getField(ExportField field) {
    switch (field) {
      case ExportField.uid:
        return uid;
      case ExportField.name:
        return name;
      case ExportField.department:
        return department;
      case ExportField.roll:
        return roll;
      case ExportField.semester:
        return semester;
      case ExportField.email:
        return email;
      case ExportField.github:
        return github;
      case ExportField.linkedin:
        return linkedin;
      case ExportField.addedOn:
        return addedOn != null ? addedOn!.toLocal().toString() : '';
      case ExportField.leftOn:
        return leftOn != null ? leftOn!.toLocal().toString() : '';
      case ExportField.attendedFullMeeting:
        return attendedFullMeeting ? 'Yes' : 'No';

      default:
        return '';
    }
  }

  @override
  Map<String, dynamic> exportData({List<ExportField> fields = const []}) =>
      fields
          .fold({}, (map, field) => map..addAll({field.name: getField(field)}));
}
