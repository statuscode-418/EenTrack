import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/screen/meeting_details_screen/components/participant_card.dart';
import 'package:flutter/material.dart';

class AttendeeSearchDelegate extends SearchDelegate {
  final List<ParticipantModel> attendees;
  final List<CheckpointModel> checkpoints;

  AttendeeSearchDelegate(this.attendees, this.checkpoints);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildAttendeeList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildAttendeeList(context);
  }

  Widget _buildAttendeeList(BuildContext context) {
    final List<ParticipantModel> filteredAttendees = query.isEmpty
        ? attendees
        : attendees
            .where((attendee) =>
                attendee.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    return ListView.builder(
      itemCount: filteredAttendees.length,
      itemBuilder: (context, index) {
        final participant = filteredAttendees[index];

        return ParticipantCard(
          participant: participant,
          checkpoints: checkpoints,
          onTap: (){
            // [TODO] Navigate to details screen
          }
        );
      },
    );
  }
}
