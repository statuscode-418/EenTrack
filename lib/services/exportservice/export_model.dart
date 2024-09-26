import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';

class ExportDataModel {
  final List<ParticipantModel> participants;
  final List<CheckpointModel> checkPoints;
  final List<String> headers = [];
  final List<Map<String, dynamic>> dataMapList = [];

  ExportDataModel(this.participants, this.checkPoints) {
    for (var participant in participants) {
      var dataMap = {
        'id': participant.userId,
        'name': participant.name,
        'created': participant.created.toIso8601String(),
        ...participant.data,
      };
      for (var checkPoint in checkPoints) {
        var checkPointTime = participant.getCheckPointTime(checkPoint.id);
        dataMap['${checkPoint.title} Status'] =
            checkPointTime == null ? 'Not Checked' : 'Checked';
        dataMap['${checkPoint.title} Time'] = checkPointTime?.toIso8601String() ?? '';
      }

      for (var key in dataMap.keys) {
        if (!headers.contains(key)) {
          headers.add(key);
        }
      }
      dataMapList.add(dataMap);
    }
  }

  List<String> getValuesAt(int i) {
    return headers.map((e) {
      var data = dataMapList[i][e];
      if (data is DateTime) {
        return data.toIso8601String();
      }
      return data.toString();
    }).toList();
  }

  int get length => participants.length;
  // Add bracket notation to accesss string values

  operator [](int i) => getValuesAt(i);
}
