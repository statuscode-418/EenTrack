import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:flutter/material.dart';

class ParticipantCard extends StatelessWidget {
  final ParticipantModel participant;
  final List<CheckpointModel> checkpoints;
  final VoidCallback onTap;
  const ParticipantCard({
    super.key,
    required this.participant,
    required this.checkpoints,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(participant.name),
        subtitle: Wrap(
          children: checkpoints
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CheckpointMark(
                    title: e.title,
                    isChecked: participant.isChecked(e.id),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class CheckpointMark extends StatelessWidget {
  final String title;
  final bool isChecked;
  const CheckpointMark({
    super.key,
    required this.title,
    required this.isChecked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        const SizedBox(width: 4),
        isChecked
            ? const Icon(Icons.check, color: Colors.green)
            : const Icon(Icons.close, color: Colors.red),
      ],
    );
  }
}
