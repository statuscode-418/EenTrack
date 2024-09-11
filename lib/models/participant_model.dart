class ParticipantModel {
  final String eventId;
  final String userId;
  final String name;

  final Map<String, dynamic> data;
  final List<String> checkPoints = [];

  ParticipantModel({
    required this.eventId,
    required this.userId,
    required this.name,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    for (var checkpoint in checkPoints) {
      if (data.containsKey(checkpoint)) {
        data[checkpoint] = data[checkpoint].toIso8601String();
      }
    }

    return {
      'eventId': eventId,
      'userId': userId,
      'checkPoints': checkPoints,
      'name': name,
      ...data
        ..remove('name')
        ..remove('eventId')
        ..remove('userId'),
    };
  }

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    final eventId = map['eventId'];
    final userId = map['userId'];
    final name = map['name'];
    final checkPoints = List<String>.from(map['checkPoints']);
    var data = map
      ..remove('eventId')
      ..remove('userId')
      ..remove('name')
      ..remove('checkPoints');

    data = data.map((key, value) {
      if (checkPoints.contains(key)) {
        return MapEntry(key, DateTime.parse(value));
      }
      return MapEntry(key, value);
    });

    return ParticipantModel(
      eventId: eventId,
      userId: userId,
      name: name,
      data: data,
    );
  }

  dynamic operator [](String key) => data[key];
  void operator []=(String key, dynamic value) => data[key] = value;
  void remove(String key) => data.remove(key);

  void markCheckPoint(String checkPointId) {
    if (!checkPoints.contains(checkPointId)) {
      checkPoints.add(checkPointId);
    }
    data[checkPointId] = DateTime.now();
  }

  void unmarkCheckPoint(String checkPointId) {
    checkPoints.remove(checkPointId);
    data.remove(checkPointId);
  }

  bool isChecked(String checkPointId) {
    return data.containsKey(checkPointId);
  }
}
