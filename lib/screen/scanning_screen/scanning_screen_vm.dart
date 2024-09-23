import 'dart:async';

import 'package:eentrack/helpers/appvm.dart';
import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanningScreenVm extends AppVM with WidgetsBindingObserver {
  final DBModel db;
  final Meeting meeting;
  final MobileScannerController scannerController = MobileScannerController();
  CheckpointModel? _selectedCheckPoint;

  bool ready = true;
  ScanningScreenVm(super.context, {required this.db, required this.meeting}) {
    WidgetsBinding.instance.addObserver(this);

    // Start listening to the barcode events.
    scannerSubcription = scannerController.barcodes.listen(onDetectBarcode);

    // Finally, start the scanner itself.
    unawaited(scannerController.start());
    init();
  }

  StreamSubscription? _participantsSubscription;
  StreamSubscription? _checkPointsSubscription;

  Future<void> init() async {
    _participantsSubscription =
        db.getParticipantsStream(meeting.id).listen((event) {
      _participants = event;
      safeNotify();
    });
    _checkPointsSubscription =
        db.getCheckPointsStream(meeting.id).listen((event) {
      _checkPoints = event;
      safeNotify();
    });

    var time = DateTime.now();
    for (var checkPoint in _checkPoints) {
      if (checkPoint.time.isBefore(time)) {
        _selectedCheckPoint = checkPoint;
      }
    }
    _selectedCheckPoint ??= _checkPoints.firstOrNull;
    safeNotify();
  }

  StreamSubscription? scannerSubcription;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (!scannerController.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        // Restart the scanner when the app is resumed.
        // Don't forget to resume listening to the barcode events.
        scannerSubcription = scannerController.barcodes.listen(onDetectBarcode);

        unawaited(scannerController.start());
      case AppLifecycleState.inactive:
        // Stop the scanner when the app is paused.
        // Also stop the barcode events subscription.
        unawaited(scannerSubcription?.cancel());
        scannerSubcription = null;
        unawaited(scannerController.stop());
    }
  }

  CheckpointModel? get selectedCheckPoint => _selectedCheckPoint;

  List<ParticipantModel> _participants = [];
  List<CheckpointModel> _checkPoints = [];

  List<ParticipantModel> get participants => _participants
      .where((p) =>
          _selectedCheckPoint == null || p.isChecked(_selectedCheckPoint!.id))
      .toList();

  List<CheckpointModel> get checkPoints => _checkPoints;

  Future<void> onDetectBarcode(BarcodeCapture capture) async {
    if (!ready) return;
    ready = false;
    var barcode = capture.barcodes;
    for (var code in barcode) {
      var raw = code.rawValue;
      if (raw == null) continue;
      await onScan(raw);
    }
    ready = true;
  }

  Future<void> onScan(String participantId) async {
    for (var participant in _participants) {
      if (participant.userId == participantId) {
        await Navigator.of(context).pushNamed(
          '/meeting/participant',
          arguments: {
            'participant': participant,
            'checkpoints': _checkPoints,
            'pop_on_checked': true,
            'db': db,
          },
        );
        return;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid Participant'),
      ),
    );
  }

  void onCheckPointSelected(CheckpointModel? checkPoint) {
    _selectedCheckPoint = checkPoint;
    safeNotify();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop listening to the barcode events.
    unawaited(scannerSubcription?.cancel());
    scannerSubcription = null;
    _participantsSubscription?.cancel();
    _checkPointsSubscription?.cancel();
    super.dispose();
    scannerController.dispose();
  }
}
