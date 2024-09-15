import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/dialog/meetingdetails_dialog.dart';
import 'package:eentrack/screen/shared/multi_selection_switch.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../meeting_details_screen/meeting_details_screen.dart';

class NewMeetingView extends StatelessWidget {
  final User user;
  final DBModel dbprovider;
  const NewMeetingView({
    Key? key,
    required this.user,
    required this.dbprovider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void showMeetingForm() {
      showMeetingFormDialog(context, user.uid).then((value) {
        if (value != null) {
          Meeting meeting = value['meeting'];
          CheckpointModel entryCheckpoint = value['entryCheckpoint'];
          CheckpointModel exitCheckpoint = value['exitCheckpoint'];

          dbprovider.createCheckPoint(entryCheckpoint);
          dbprovider.createCheckPoint(exitCheckpoint);
          dbprovider.createMeeting(user.uid, meeting).then((value) => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MeetingDetailsScreen(
                      meeting: value,
                      dbprovider: dbprovider,
                    ),
                  ),
                )
              });
        }
      });
    }

    return Stack(
      children: [
        MeetingsList(dbprovider: dbprovider, user: user),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: showMeetingForm,
              child: const Text('New Meeting'),
            ),
          ),
        ),
      ],
    );
  }
}

enum MeetingType {
  hosted,
  coHosted,
}

extension MeetingTypeExtension on MeetingType {
  String get name {
    switch (this) {
      case MeetingType.hosted:
        return 'Hosted';
      case MeetingType.coHosted:
        return 'Co-Hosted';
      default:
        return 'Unknown';
    }
  }
}

class MeetingsList extends StatefulWidget {
  const MeetingsList({
    super.key,
    required this.dbprovider,
    required this.user,
  });

  final DBModel dbprovider;
  final User user;

  @override
  State<MeetingsList> createState() => _MeetingsListState();
}

class _MeetingsListState extends State<MeetingsList> {
  late Stream<List<Meeting>> _meetingsStream;
  late Stream<List<Meeting>> _coHostedMeetingsStream;
  late Stream<List<List<Meeting>>> _meetingsListStream;

  List<Meeting> _meetings = [];
  List<Meeting> _coHostedMeetings = [];
  MeetingType _meetingType = MeetingType.hosted;

  List<Meeting> get filteredMeetings {
    switch (_meetingType) {
      case MeetingType.hosted:
        return _meetings;
      case MeetingType.coHosted:
        return _coHostedMeetings;
      default:
        return _meetings;
    }
  }

  @override
  void initState() {
    super.initState();
    _meetingsStream = widget.dbprovider.getMeetings(widget.user.uid);
    _coHostedMeetingsStream =
        widget.dbprovider.getCoHostedMeetings(widget.user.uid);
    _meetingsListStream =
        CombineLatestStream.list([_meetingsStream, _coHostedMeetingsStream]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder<List<List<Meeting>>>(
          stream: _meetingsListStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            var data = snapshot.data as List<List<Meeting>>;
            _meetings = data[0];
            _coHostedMeetings = data[1];
            return Column(
              children: [
                MultiSelectionSwitch(
                  lables: MeetingType.values.map((e) => e.name).toList(),
                  selectedIndex: MeetingType.values.indexOf(_meetingType),
                  onChanged: (i) => setState(() {
                    _meetingType = MeetingType.values[i];
                  }),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredMeetings.length,
                    itemBuilder: (BuildContext context, index) {
                      final meeting = filteredMeetings[index];
                      return MeetingTile(
                        meeting: meeting,
                        onTap: (meeting) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MeetingDetailsScreen(
                                meeting: meeting,
                                dbprovider: widget.dbprovider,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}

class MeetingTile extends StatelessWidget {
  final Meeting meeting;
  final Function(Meeting) onTap;
  const MeetingTile({super.key, required this.meeting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
    return GestureDetector(
      onTap: () => onTap(meeting),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.person),
          title: Text(meeting.title),
          subtitle: Text(formatter.format(meeting.date)),
          trailing: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}
