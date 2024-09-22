import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/screen/shared/date_time_picker.dart';
import 'package:eentrack/screen/shared/show_snackbar.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum AttendeeFilter {
  present,
  left,
}

class MeetingListView extends StatefulWidget {
  final Meeting meeting;
  final List<ParticipantModel> participants;
  final bool entry;
  final DBModel dbModel;

  const MeetingListView(
      {super.key,
      required this.meeting,
      required this.participants,
      required this.entry,
      required this.dbModel});

  @override
  State<MeetingListView> createState() => _MeetingListViewState();
}

class _MeetingListViewState extends State<MeetingListView> {
  DateTime? dateTime;

  Map<AttendeeFilter, bool> filter = {
    AttendeeFilter.present: false,
    AttendeeFilter.left: false,
  };

  List<ParticipantModel> get filteredAttendees {
    var filtered = widget.participants;
    for (var key in filter.keys) {
      if (filter[key]!) {
        switch (key) {
          case AttendeeFilter.present:
            // filtered = filtered.where((element) => element.isPresent).toList();
            break;
          case AttendeeFilter.left:
            // filtered = filtered.where((element) => element.isLeft).toList();
            break;
        }
      }
    }
    return filtered;
  }

  void _addCheckpointDialog() {
    final TextEditingController checkpointController = TextEditingController();
    setState(() {
      dateTime = null;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AlertDialog(
            title: const Text("Add Checkpoint"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: checkpointController,
                  decoration:
                      const InputDecoration(hintText: "Enter checkpoint title"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    final selectedDateTime =
                        await showDateTimePicker(context, 'Select a time');
                    if (selectedDateTime != null) {
                      setState(() {
                        dateTime = selectedDateTime;
                      });
                    }
                  },
                  child: Text(
                    dateTime != null
                        ? 'Check point time: ${DateFormat('dd-MM-yyyy, hh:mm a').format(dateTime!)}'
                        : 'Select Entry Time',
                  ),
                )
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  if (checkpointController.text.isNotEmpty &&
                      dateTime != null) {
                    final checkpoint = CheckpointModel(
                      id: const Uuid().v4(),
                      mid: widget.meeting.id,
                      uid: widget.meeting.hostid,
                      title: checkpointController.text,
                      time: dateTime!,
                    );

                    await widget.dbModel.createCheckPoint(checkpoint);

                    for (var participant in widget.participants) {
                      participant.markCheckPoint(checkpoint.id);

                      await widget.dbModel.updateParticipant(participant);
                    }

                    Navigator.of(context).pop();
                  } else {
                    showSnackbar(context,
                        'Please fill all fields before adding a checkpoint.');
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: StreamBuilder<List<CheckpointModel>>(
            stream: widget.dbModel.getCheckPointsStream(widget.meeting.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading checkpoints'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No checkpoints available'));
              }
    
              final checkpoints = snapshot.data!;
    
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: checkpoints
                          .map((e) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Chip(
                                  label: Text(e.title),
                                ),
                              ))
                          .toList(),
                    ),
                    IconButton(
                      onPressed: _addCheckpointDialog,
                      icon: const Icon(Icons.add),
                    )
                  ]);
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Total: ${filteredAttendees.length}",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final participant = filteredAttendees[index];
                final participantCheckpoints = participant.checkPoints;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(participant.name),
                    ),
                    Row(
                      children: List.generate(
                        participantCheckpoints.length,
                        (index) => Icon(
                          participant.isChecked(participantCheckpoints[index])
                              ? Icons.check
                              : Icons.clear,
                          color: participant
                                  .isChecked(participantCheckpoints[index])
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                    const Divider(),
                  ],
                );
              },
              childCount: filteredAttendees.length,
            ),
          ),
        )
      ],
    );
  }
}
