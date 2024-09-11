import 'package:eentrack/models/export_fields.dart';

import 'model.dart';
import 'model_consts.dart' as consts;

class Meeting implements DataModel {
  final String id;
  final String hostid;
  final bool isHost;
  final List<String> coHosts;
  final String title;
  final String description;
  final DateTime date;

  Meeting({
    required this.id,
    required this.hostid,
    required this.isHost,
    required this.coHosts,
    required this.title,
    required this.description,
    required this.date,
  });

  Meeting copyWith({
    String? id,
    String? hostid,
    String? title,
    String? description,
    DateTime? date,
    double? latitude,
    double? longitude,
  }) {
    return Meeting(
      id: id ?? this.id,
      hostid: hostid ?? this.hostid,
      coHosts: coHosts,
      isHost: isHost,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      consts.id: id,
      consts.hostid: hostid,
      consts.coHosts: coHosts,
      consts.title: title,
      consts.description: description,
      consts.date: date.millisecondsSinceEpoch,
    };
  }

  factory Meeting.fromMap(Map<String, dynamic> map, String uid) {
    return Meeting(
      id: map[consts.id],
      hostid: map[consts.hostid],
      coHosts: map[consts.coHosts].cast<String>(),
      isHost: map[consts.hostid] == uid,
      title: map[consts.title],
      description: map[consts.description],
      date: DateTime.fromMillisecondsSinceEpoch(map[consts.date]),
    );
  }
  Meeting.newMeeting({
    required this.id,
    required this.hostid,
    required this.title,
    required this.description,
  })  : coHosts = [],
        isHost = true,
        date = DateTime.now();

  @override
  Map<String, dynamic> exportData({List<ExportField> fields = const []}) {
    // TODO: implement exportData
    throw UnimplementedError();
  }
}
