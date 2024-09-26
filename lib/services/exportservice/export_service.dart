import 'dart:core';
import 'dart:io';

import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/services/exportservice/export_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

import '../../models/model.dart';

class ExportService {
  Future<void> toExcel(String filename, List<ParticipantModel> participants,
      List<CheckpointModel> checkPoints) async {
    var exportData = ExportDataModel(participants, checkPoints);
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];

    sheet.appendRow(exportData.headers
        .map((e) => TextCellValue(
              e,
            ))
        .toList());

    for (int i = 0; i < exportData.length; i++) {
      List<CellValue> cellList =
          exportData[i].map<CellValue>((e) => TextCellValue(e)).toList();
      sheet.appendRow(cellList);
    }

    // var status = await Permission.storage.status;
    // if (status == PermissionStatus.denied) {
    //   status = await Permission.storage.request();
    // }

    // if (status == PermissionStatus.denied) {
    //   throw ExportError('Permission denied');
    // }

    var fileBytes = excel.save();
    var directory = await getTemporaryDirectory();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    debugPrint(directory.path);
    var file = File('${directory.path}/$filename.xlsx')
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    var xf = XFile(file.path);
    await Share.shareXFiles([xf]);
  }

  Future<void> toCSV(String filename, List<ParticipantModel> participants,
      List<CheckpointModel> checkpoints) async {
    var exportData = ExportDataModel(participants, checkpoints);
    var csv = StringBuffer();
    csv.writeln(exportData.headers.join(','));
    for (int i = 0; i < exportData.length; i++) {
      csv.writeln(exportData[i].join(','));
    }

    var directory = await getTemporaryDirectory();
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    var file = File('${directory.path}/$filename.csv')
      ..createSync(recursive: true)
      ..writeAsStringSync(csv.toString());

    final xf = XFile(file.path);
    await Share.shareXFiles([xf]);
  }

  Future<void> toPdf(String path, List<DataModel> data) async {
    // TODO: implement toPdf
    throw UnimplementedError();
  }
}

class ExportError implements Exception {
  final String message;
  ExportError(this.message);
}
