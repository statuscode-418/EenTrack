import 'dart:core';
import 'dart:io';

import 'package:eentrack/models/export_fields.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:eentrack/services/exportservice/export_model.dart';

import '../../models/model.dart';

class ExportService implements ExportModel {
  @override
  Future<void> toExcel(
      String filename, List<DataModel> data, List<ExportField> fields) async {
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];
    if (data.isNotEmpty) {
      var d = data[0].exportData(
        fields: fields,
      );
      sheet.appendRow(d.keys.map((e) => TextCellValue(e)).toList());
      for (var d in data) {
        var map = d.exportData(
          fields: fields,
        );
        sheet.appendRow(map.values.map((e) => TextCellValue(e)).toList());
      }
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

  @override
  Future<void> toPdf(String path, List<DataModel> data) async {
    // TODO: implement toPdf
    throw UnimplementedError();
  }
}

class ExportError implements Exception {
  final String message;
  ExportError(this.message);
}
