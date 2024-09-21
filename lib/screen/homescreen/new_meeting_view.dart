import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/dialog/meetingdetails_dialog.dart';
import 'package:eentrack/screen/homescreen/home_screen_vm.dart';
import 'package:eentrack/screen/shared/multi_selection_switch.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../meeting_details_screen/meeting_details_screen.dart';

class NewMeetingView extends StatelessWidget {
  const NewMeetingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeScreenVM>();
    return Stack(
      children: [
        MeetingsList(),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: vm.showMeetingForm,
              child: const Text('New Meeting'),
            ),
          ),
        ),
      ],
    );
  }
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

class MeetingsList extends StatelessWidget {
  const MeetingsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<HomeScreenVM>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          MultiSelectionSwitch(
            lables: MeetingType.values.map((e) => e.name).toList(),
            selectedIndex: vm.type.index,
            onChanged: (i) {
              vm.changeType(MeetingType.values[i]);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: vm.meetings.length,
              itemBuilder: (BuildContext context, index) {
                return MeetingTile(
                  meeting: vm.meetings[index],
                  onTap: (meeting) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MeetingDetailsScreen(
                          meeting: meeting,
                          dbprovider: vm.db,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
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
