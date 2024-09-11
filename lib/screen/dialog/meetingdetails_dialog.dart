import 'dart:io';

import 'package:eentrack/models/meeting_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<Meeting?> showMeetingFormDialog(BuildContext context, String uid) async {
  String title = '';
  String description = '';
  File? selectedFile;

  return showDialog(
      context: context,
      builder: (BuildContext context) {
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
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls'],
                  );
                },
                child: const Text('Upload Excel File'),
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
                String mid = DateTime.now().millisecondsSinceEpoch.toString();
                var meeting = Meeting.newMeeting(
                    id: mid,
                    hostid: uid,
                    title: title,
                    description: description);
                Navigator.of(context).pop(meeting);
              },
              child: const Text('Create'),
            ),
          ],
        );
      });
}
