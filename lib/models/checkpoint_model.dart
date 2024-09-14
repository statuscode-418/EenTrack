import 'model_consts.dart' as consts;

class CheckpointModel {
  final String id;
  final String mid;
  final String uid;
  final String title;
  final DateTime time;

  CheckpointModel({
    required this.id,
    required this.mid,
    required this.uid,
    required this.title,
    required this.time,
  });

  CheckpointModel copyWith({
    String? id,
    String? mid,
    String? uid,
    String? title,
    DateTime? time,
  }) {
    return CheckpointModel(
      id: id ?? this.id,
      mid: mid ?? this.mid,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      consts.id: id,
      consts.mid: mid,
      consts.uid: uid,
      consts.title: title,
      consts.time: time.toIso8601String(),
    };
  }

  factory CheckpointModel.fromMap(Map<String, dynamic> map) {
    return CheckpointModel(
      id: map[consts.id],
      mid: map[consts.mid],
      uid: map[consts.uid],
      title: map[consts.title],
      time: DateTime.parse(map[consts.time]),
    );
  }
}
