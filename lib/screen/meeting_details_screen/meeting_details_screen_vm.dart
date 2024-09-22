import 'dart:async';

import 'package:eentrack/helpers/appvm.dart';
import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/dialog/alart_dialog.dart';
import 'package:eentrack/screen/dialog/scanner_dialog.dart';
import 'package:eentrack/screen/meeting_details_screen/components/add_checkpoint_dialog.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:eentrack/services/qr_service/qr_parser.dart';
import 'package:flutter/material.dart';

class MeetingDetailsScreenVM extends AppVM {
  Meeting meeting;
  User user;
  DBModel db;

  MeetingDetailsScreenVM(
    super.context, {
    required this.user,
    required this.meeting,
    required this.db,
  }) {
    init();
  }

  bool _loading = true;
  bool get loading => _loading;

  StreamSubscription? _participantSub;
  StreamSubscription? _checkpointSub;

  Future<void> init() async {
    _loading = true;
    _checkpoints = await db.getCheckPoints(meeting.id);
    _participants = await db.getParticipants(meeting.id);
    _coHosts = await db.getUsers(meeting.coHosts);

    _participantSub = db.getParticipantsStream(meeting.id).listen((event) {
      _participants = event;
      safeNotify();
    });

    _checkpointSub = db.getCheckPointsStream(meeting.id).listen((event) {
      _checkpoints = event;
      safeNotify();
    });
    _loading = false;
    safeNotify();
  }

  List<User> _coHosts = [];
  List<CheckpointModel> _checkpoints = [];
  List<ParticipantModel> _participants = [];

  List<User> get coHosts => _coHosts;

  List<ParticipantModel> get participants {
    if (_checkpointFilter == null) return _participants;
    return _participants
        .where((p) => p.isChecked(_checkpointFilter!.id))
        .toList();
  }

  List<CheckpointModel> get checkpoints => _checkpoints;

  CheckpointModel? _checkpointFilter;
  CheckpointModel? get checkpointFilter => _checkpointFilter;

  Future<void> createCheckpoint() async {
    final checkpoint =
        await showAddCheckpointDialog(context, meeting.id, user.uid);
    if (checkpoint == null) return;
    await db.createCheckPoint(checkpoint);
  }

  Future<void> deleteCheckpoint(CheckpointModel checkpoint) async {
    var confirm = await showAlartDialog(
        'Delete Checkpoint', 'You sure want to delete checkpoint?', context);
    if (confirm != Option.ok) return;
    await db.deleteCheckPoint(checkpoint);
  }

  void toggleCheckpointFilter(CheckpointModel? checkpoint) {
    _checkpointFilter = checkpoint;
    safeNotify();
  }

  void addCohost() async {
    var rawData =
        await showScannerDialog(context: context, title: 'Add Co-Host');
    if (rawData == null) return;
    var coHostId = QrParser.parseHost(rawData);
    if (meeting.coHosts.contains(coHostId)) {
      return;
    }
    var user = await db.getUser(coHostId);
    if (user == null) {
      return;
    }
    meeting.coHosts.add(coHostId);
    await db.updateMeeting(user.uid, meeting);
    _coHosts.add(user);
    safeNotify();
  }

  void removeCohost(User coHost) async {
    var result = await showAlartDialog(
        'Delete Co-Host', 'You sure want to delete co-host?', context);
    if (result != Option.ok) return;
    meeting.coHosts.remove(coHost.uid);
    await db.updateMeeting(user.uid, meeting);
    _coHosts.remove(coHost);
    safeNotify();
  }

  Future<void> shareDetails() async {
    // [TODO] Impliment share with new participants model
  }

  void deleteMeeting() async {
    var result = await showAlartDialog(
        'Delete Meeting', 'You sure want to delete meeting?', context);
    if (result != Option.ok) return;
    await db.deleteMeeting(user.uid, meeting.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _participantSub?.cancel();
    _checkpointSub?.cancel();
    super.dispose();
  }
}
