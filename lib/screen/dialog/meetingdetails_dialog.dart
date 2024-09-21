import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/screen/shared/date_time_picker.dart';
import 'package:eentrack/screen/shared/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

Future<Map<String, dynamic>?> showMeetingFormDialog(
    BuildContext context, String uid) async {
  String title = '';
  String description = '';
  DateTime? entryTime;
  DateTime? exitTime;
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Enter Meeting Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Meeting Name',
                    ),
                    onChanged: (nm) {
                      title = nm;
                    },
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Meeting Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                    ),
                    maxLines: null,
                    onChanged: (des) {
                      description = des;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDateTimePicker(
                          context, 'Select Entry Time');
                      if (picked != null) {
                        setState(() {
                          entryTime = picked;
                        });
                      }
                    },
                    child: Text(
                      entryTime != null
                          ? 'Entry Time: ${DateFormat('dd-MM-yyyy, hh:mm a').format(entryTime!)}'
                          : 'Select Entry Time',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final picked =
                          await showDateTimePicker(context, 'Select Exit Time');
                      if (picked != null) {
                        setState(() {
                          exitTime = picked;
                        });
                      }
                    },
                    child: Text(
                      exitTime != null
                          ? 'Exit Time: ${DateFormat('dd-MM-yyyy, hh:mm a').format(exitTime!)}'
                          : 'Select Exit Time',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (entryTime == null || exitTime == null) {
                      showSnackbar(context, 'Please fill all fields');
                      return;
                    }
                    if (entryTime!.isAfter(exitTime!)) {
                      showSnackbar(
                          context, 'Entry time cannot be after exit time');
                      return;
                    }

                    if (entryTime!.isBefore(DateTime.now())) {
                      showSnackbar(context, 'Entry time cannot be in the past');
                      return;
                    }

                    String mid =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    var meeting = Meeting.newMeeting(
                        id: mid,
                        hostid: uid,
                        title: title,
                        description: description);

                    var uuid = const Uuid();

                    var entryCheckPoint = CheckpointModel(
                      id: uuid.v4(),
                      mid: mid,
                      uid: uid,
                      title: 'Entry',
                      time: entryTime!,
                    );
                    var exitCheckPoint = CheckpointModel(
                      id: uuid.v4(),
                      mid: mid,
                      uid: uid,
                      title: 'Exit',
                      time: exitTime!,
                    );

                    Navigator.of(context).pop({
                      'meeting': meeting,
                      'entryCheckpoint': entryCheckPoint,
                      'exitCheckpoint': exitCheckPoint,
                    });
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      });
}
