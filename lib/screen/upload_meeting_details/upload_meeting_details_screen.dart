import 'dart:typed_data';
import 'dart:io';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/screen/shared/show_snackbar.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadMeetingDetailsScreen extends StatefulWidget {
  final String meetingId;
  final DBModel dbProvider;
  const UploadMeetingDetailsScreen({
    super.key,
    required this.meetingId,
    required this.dbProvider,
  });

  @override
  State<UploadMeetingDetailsScreen> createState() =>
      _UploadMeetingDetailsScreenState();
}

class _UploadMeetingDetailsScreenState
    extends State<UploadMeetingDetailsScreen> {
  List<String> excelHeaders = [];
  List<List<dynamic>> excelData = [];

  String? selectedNameField;
  String? selectedUserIdField;
  int selectedRow = 1;

  Future<void> _pickAndReadExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;

      if (fileBytes == null && result.files.first.path != null) {
        final filePath = result.files.first.path!;
        final File file = File(filePath);
        fileBytes = await file.readAsBytes();
      }
      if (fileBytes != null) {
        var excel = Excel.decodeBytes(fileBytes);

        var sheet = excel.sheets[excel.tables.keys.first]!;

        setState(() {
          excelHeaders = sheet.rows.first.where((header) {
            return header != null && header.value != null;
          }).map((header) {
            return header?.value?.toString() ?? '';
          }).toList();

          excelData = sheet.rows.sublist(1);
        });

        _showFieldMappingDialog();
      }
    }
  }

  void _showFieldMappingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Map Excel Fields'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              hint: const Text('Select Name Field'),
              items: excelHeaders.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(field),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNameField = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              hint: const Text('Select user Id Field (Optional)'),
              value: selectedUserIdField,
              items: excelHeaders.map((field) {
                return DropdownMenuItem(
                  value: field,
                  child: Text(field),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedUserIdField = value;
                });
              },
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadParticipants();
            },
            child: const Text('Upload'),
          )
        ],
      ),
    );
  }

  Future<void> _uploadParticipants() async {
    if (selectedNameField == null) {
      showSnackbar(context, 'Please select a name filed');
      return;
    }

    final nameIndex = excelHeaders.indexOf(selectedNameField!);
    final userIdIndex = selectedUserIdField != null
        ? excelHeaders.indexOf(selectedUserIdField!)
        : -1;

    for (var row in excelData) {
      final String name = row[nameIndex]?.value.toString() ?? '';
      final String userId = userIdIndex != -1
          ? row[userIdIndex]?.value.toString() ?? ''
          : const Uuid().v4();

      final Map<String, dynamic> data = {};

      for (int j = 0; j < row.length; j++) {
        if (j != nameIndex && j != userIdIndex) {
          data[excelHeaders[j]] = row[j].value.toString();
        }
      }
      final time = DateTime.now();

      final participant = ParticipantModel(
        eventId: widget.meetingId,
        userId: userId,
        name: name,
        data: data,
        created: time,
        lastUpdated: time,
      );
      widget.dbProvider.addParticipant(participant);
    }

    showSnackbar(context, 'Patricipants uploaded successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Meeting Details'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _pickAndReadExcelFile,
          child: const Text('Upload Excel File'),
        ),
      ),
    );
  }
}
