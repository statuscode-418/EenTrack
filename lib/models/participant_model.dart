class ParticipantModel {
  final String eventId;
  final String userId;
  final String name;
  DateTime lastUpdated;
  final DateTime created;

  final Map<String, dynamic> data;
  final Map<String, DateTime> checkPoints;

  ParticipantModel({
    required this.eventId,
    required this.userId,
    required this.name,
    required this.data,
    required this.lastUpdated,
    required this.created,
    this.checkPoints = const <String, DateTime>{},
  });

  Map<String, dynamic> toJson() {
    var checkPointsList = checkPoints.keys.toList();
    var checkPointsMap = <String, String>{};
    for (var key in checkPoints.keys) {
      var isoString = checkPoints[key]?.toIso8601String();
      if (isoString != null) {
        checkPointsMap[key] = isoString;
      }
    }
    var exportDate = {
      'eventId': eventId,
      'userId': userId,
      'checkPoints': checkPointsList,
      'name': name,
      'lastUpdated': lastUpdated.toIso8601String(),
      'created': created.toIso8601String(),
      ...data,
      ...checkPointsMap,
    };

    return exportDate;
  }

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    final eventId = map['eventId'];
    final userId = map['userId'];
    final name = map['name'];
    final lastUpdated = DateTime.parse(map['lastUpdated']);
    final created = DateTime.parse(map['created']);

    map
      ..remove('eventId')
      ..remove('userId')
      ..remove('name')
      ..remove('lastUpdated')
      ..remove('created');

    final checkPoints = List<String>.from(map['checkPoints']);
    map.remove('checkPoints');
    final checkPointsMap = <String, DateTime>{};

    for (var key in checkPoints) {
      checkPointsMap[key] = DateTime.parse(map[key]);
      map.remove(key);
    }

    return ParticipantModel(
        eventId: eventId,
        userId: userId,
        created: created,
        lastUpdated: lastUpdated,
        name: name,
        data: map,
        checkPoints: checkPointsMap);
  }

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;
  void remove(String key) => data.remove(key);

  void markCheckPoint(String checkPointId) {
    checkPoints[checkPointId] = DateTime.now();
    lastUpdated = DateTime.now();
  }

  void unmarkCheckPoint(String checkPointId) {
    checkPoints.remove(checkPointId);
    lastUpdated = DateTime.now();
  }

  bool isChecked(String checkPointId) {
    return checkPoints.containsKey(checkPointId);
  }

  DateTime? getCheckPointTime(String checkPointId) {
    return checkPoints[checkPointId];
  }
}
