import 'package:eentrack/models/attendee_model.dart';
import 'package:eentrack/models/export_fields.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/screen/dialog/alart_dialog.dart';
import 'package:eentrack/screen/meeting_details_screen/components/attendee_search_delegate.dart';
import 'package:eentrack/screen/meeting_details_screen/components/co_host_manager.dart';
import 'package:eentrack/screen/meeting_details_screen/meeting_details_view.dart';
import 'package:eentrack/screen/scanning_screen/scanning_screen.dart';
import 'package:eentrack/screen/upload_meeting_details/upload_meeting_details_screen.dart';
import 'package:eentrack/services/exportservice/export_service.dart';
import 'package:flutter/material.dart';

import '../../services/dbservice/db_model.dart';

enum PopupMenu { export, cohost, delete }

extension PopupMenuExtension on PopupMenu {
  String get value {
    switch (this) {
      case PopupMenu.export:
        return 'export';
      case PopupMenu.cohost:
        return 'cohost';
      case PopupMenu.delete:
        return 'delete';
    }
  }

  IconData get icon {
    switch (this) {
      case PopupMenu.export:
        return Icons.share;
      case PopupMenu.cohost:
        return Icons.person_add;
      case PopupMenu.delete:
        return Icons.delete;
    }
  }
}

class MeetingDetailsScreen extends StatefulWidget {
  final Meeting meeting;
  final DBModel dbprovider;
  const MeetingDetailsScreen({
    super.key,
    required this.meeting,
    required this.dbprovider,
  });

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  var entry = true;
  var exportprovider = ExportService();
  List<Attendee> attendees = [];

  void _deleteMeeting() async {
    var result = await showAlartDialog(
        'Delete Meeting', 'You sure want to delete meeting?', context);
    if (result != Option.ok) return;
    await widget.dbprovider
        .deleteMeeting(widget.meeting.hostid, widget.meeting.id);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  void _exportToExcel() {
    exportprovider.toExcel(widget.meeting.title, attendees, [
      ExportField.uid,
      ExportField.name,
      ExportField.addedOn,
      ExportField.leftOn,
      ExportField.attendedFullMeeting,
    ]);
  }

  void _scanAttendee() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ScanningScreen(
          dbprovider: widget.dbprovider,
          meeting: widget.meeting,
        ),
      ),
    );
  }

  void _addCohost() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          CoHostManager(meeting: widget.meeting, db: widget.dbprovider),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton(
      itemBuilder: (context) => PopupMenu.values
          .map((e) => PopupMenuItem(
                value: e,
                child: Row(
                  children: [
                    Icon(e.icon),
                    const SizedBox(width: 10),
                    Text(e.value),
                  ],
                ),
              ))
          .toList(),
      onSelected: (PopupMenu result) {
        switch (result) {
          case PopupMenu.export:
            _exportToExcel();
            break;
          case PopupMenu.cohost:
            _addCohost();
            break;
          case PopupMenu.delete:
            _deleteMeeting();
            break;
        }
      },
    );
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UploadMeetingDetailsScreen(
                  meetingId: widget.meeting.id,
                  dbProvider: widget.dbprovider,
                ),
              ),
            );
          },
          icon: const Icon(
            Icons.upload,
          )),
      IconButton(
        onPressed: () => showSearch(
            context: context, delegate: AttendeeSearchDelegate(attendees)),
        icon: const Icon(Icons.search),
      ),
      if (widget.meeting.isHost) _buildPopupMenu(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.title),
        actions: _buildActions(),
      ),
      body: StreamBuilder<List<ParticipantModel>>(
          stream: widget.dbprovider.getParticipants(widget.meeting.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            List<ParticipantModel> participants = snapshot.data!;

            return MeetingDetailsView(
              meeting: widget.meeting,
              entry: entry,
              participants: participants,
              dbModel: widget.dbprovider,
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanAttendee,
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
