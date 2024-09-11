class ParticipantModel {
  final String eventId;
  final String userId;
  final String name;

  final Map<String, dynamic> data;

  ParticipantModel({
    required this.eventId,
    required this.userId,
    required this.name,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
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
    final data = map
      ..remove('name')
      ..remove('eventId')
      ..remove('userId');

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
    data[checkPointId] = true;
  }

  void unmarkCheckPoint(String checkPointId) {
    data.remove(checkPointId);
  }

  bool isChecked(String checkPointId) {
    return data.containsKey(checkPointId);
  }
}
