import 'dart:async';

import 'package:eentrack/bloc/authbloc/auth_bloc.dart';
import 'package:eentrack/bloc/authbloc/auth_events.dart';
import 'package:eentrack/helpers/appvm.dart';
import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/dialog/alart_dialog.dart';
import 'package:eentrack/screen/dialog/meetingdetails_dialog.dart';
import 'package:eentrack/screen/dialog/user_settings_dialog.dart';
import 'package:eentrack/screen/meeting_details_screen/meeting_details_screen.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:eentrack/services/qr_service/qr_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreenVM extends AppVM {
  final DBModel db;
  final User user;

  bool _isInitialized = false;

  MeetingType _type = MeetingType.hosted;
  StreamSubscription? _meetingSubscription;

  StreamSubscription? _cohostedMeetingSubscription;

  List<Meeting> _hostedMeetings = [];

  List<Meeting> _cohostedMeetings = [];
  PageController homePageController = PageController(
    initialPage: 1,
  );

  int pageNo = 1;
  HomeScreenVM(
    super.context, {
    required this.user,
    required this.db,
  }) {
    init();
  }

  bool get isInitialized => _isInitialized;
  List<Meeting> get meetings {
    if (_type == MeetingType.hosted) {
      return _hostedMeetings;
    } else {
      return _cohostedMeetings;
    }
  }

  MeetingType get type => _type;

  String get userQrString => QrParser.encodeUid(user.uid);

  void changeType(MeetingType type) {
    _type = type;
    safeNotify();
  }

  @override
  void dispose() {
    _meetingSubscription?.cancel();
    _cohostedMeetingSubscription?.cancel();
    super.dispose();
  }

  Future<void> init() async {
    var allMeetings = await Future.wait([
      db.getMeetings(user.uid),
      db.getCoHostedMeetings(user.uid),
    ]);

    _hostedMeetings = allMeetings[0];
    _cohostedMeetings = allMeetings[1];

    _meetingSubscription = db.getMeetingsStream(user.uid).listen(
      (meetings) {
        _hostedMeetings = meetings;
        safeNotify();
      },
      onError: (error) {
        safeShowSnackbar(error.toString(), error: true);
      },
    );

    _cohostedMeetingSubscription =
        db.getCoHostedMeetingsStream(user.uid).listen(
      (meetings) {
        _cohostedMeetings = meetings;
        safeNotify();
      },
      onError: (error) {
        safeShowSnackbar(error.toString(), error: true);
      },
    );

    _isInitialized = true;
  }

  Future<void> showMeetingForm() async {
    var value = await showMeetingFormDialog(context, user.uid);
    if (value == null) return;
    Meeting meeting = value['meeting'];
    CheckpointModel entryCheckpoint = value['entryCheckpoint'];
    CheckpointModel exitCheckpoint = value['exitCheckpoint'];

    db.createCheckPoint(entryCheckpoint);
    db.createCheckPoint(exitCheckpoint);
    meeting = await db.createMeeting(user.uid, meeting);
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingDetailsView(
          meeting: meeting,
          dbprovider: db,
        ),
      ),
    );
  }

  void showSettings() async {
    var res = await showSettingsDialog(context, user);
    if (res == null) return;
    if (res == SettingOptions.editProfile) _editProfile();
    if (res == SettingOptions.logout) _logout();
  }

  void switchPage(int i) {
    pageNo = i;
    homePageController.animateToPage(
      pageNo,
      curve: Curves.easeInOutCubic,
      duration: const Duration(milliseconds: 250),
    );
    safeNotify();
  }

  void _editProfile() {
    if (!context.mounted) return;
    BlocProvider.of<AuthBloc>(context).add(
      AuthEventShowUpdateUserDetails(user: user),
    );
  }

  void _logout() async {
    var res = await showAlartDialog(
        'Loging Out', 'You sure want to log out?', context);
    if (res != Option.ok) return;
    if (!context.mounted) return;
    BlocProvider.of<AuthBloc>(context).add(AuthEventLogout());
  }
}

enum MeetingType {
  hosted,
  coHosted,
}
