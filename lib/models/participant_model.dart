class ParticipantModel {
  final String eventId;
  final String userId;

  final Map<String, dynamic> data;

  ParticipantModel({
    required this.eventId,
    required this.userId,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      ...data,
    };
  }

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    final eventId = map['eventId'];
    final userId = map['userId'];
    final data = map
      ..remove('eventId')
      ..remove('userId');

    return ParticipantModel(
      eventId: eventId,
      userId: userId,
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
