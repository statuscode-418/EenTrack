import 'package:eentrack/models/attendee_model.dart';
import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';

class ScannerView extends StatelessWidget {
  final User user;
  final DBModel dbprovider;
  const ScannerView({
    super.key,
    required this.user,
    required this.dbprovider,
  });

  @override
  Widget build(BuildContext context) {
    String? code;
    final qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();

    bool isCodeValid(String code) {
      if (code.isEmpty) {
        return false;
      }
      if (!code.contains('@')) {
        return false;
      }
      var parts = code.split('@');
      if (parts.length != 2) {
        return false;
      }
      if (parts[0].isEmpty || parts[1].isEmpty) {
        return false;
      }
      return true;
    }

    void openCameraAndScan() {
      qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
        context: context,
        onCode: (code) {
          // TODO: Add a validation for the code
          code = code ?? '';
          if (!isCodeValid(code)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid QR Code'),
              ),
            );
            return;
          }
          var parts = code.split('@');
          var hostid = parts[0];
          var meetingid = parts[1];
          var attendee = Attendee(
            uid: user.uid,
            name: user.name,
            roll: user.roll,
            semester: user.semester,
            department: user.department,
            email: user.email,
            linkedin: user.linkedin,
            github: user.github,
          );
          dbprovider.addAttendee(hostid, meetingid, attendee).then((value) => {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attendance Marked'),
                  ),
                )
              });
        },
      );
    }

    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: IconButton(
            onPressed: () {
              openCameraAndScan();
            },
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              size: 250,
            ),
          ),
        ));
  }
}
