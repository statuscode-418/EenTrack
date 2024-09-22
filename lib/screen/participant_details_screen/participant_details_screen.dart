import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';

class ParticipantDetailsScreen extends StatefulWidget {
  const ParticipantDetailsScreen({super.key});

  @override
  State<ParticipantDetailsScreen> createState() =>
      _ParticipantDetailsScreenState();
}

class _ParticipantDetailsScreenState extends State<ParticipantDetailsScreen> {
  late ParticipantModel participant;
  late List<CheckpointModel> checkPoints;
  late bool popOnChecked;
  late DBModel db;

  @override
  void initState() {
    super.initState();
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    participant = args['participant'] as ParticipantModel;
    checkPoints = args['checkpoints'] as List<CheckpointModel>;
    popOnChecked = args['pop_on_checked'] as bool? ?? false;
    db = args['db'] as DBModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(participant.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: participant.data.entries
                  .map(
                    (e) => ListTile(
                      title: Text(e.key),
                      subtitle: Text(e.value.toString()),
                    ),
                  )
                  .toList(),
            ),
          ),
          Wrap(
            children: checkPoints
                .map(
                  (e) => CheckpointChip(
                    title: e.title,
                    isChecked: participant.isChecked(e.id),
                    onTap: () async {
                      if (participant.isChecked(e.id)) {
                        participant.unmarkCheckPoint(e.id);
                        await db.markCheckPoint(
                          participant.eventId,
                          participant.userId,
                          e.id,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${participant.name} | ${e.title} unchechecked'),
                          ),
                        );
                      } else {
                        participant.markCheckPoint(e.id);
                        await db.unmarkCheckPoint(
                          participant.eventId,
                          participant.userId,
                          e.id,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${participant.name} | ${e.title} chechecked'),
                          ),
                        );
                      }
                      if (popOnChecked) {
                        Navigator.of(context).pop();
                      }
                      setState(() {});
                    },
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class CheckpointChip extends StatelessWidget {
  final String title;
  final bool isChecked;
  final VoidCallback? onTap;
  const CheckpointChip({
    super.key,
    required this.title,
    required this.isChecked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(title),
        avatar: Icon(
          isChecked ? Icons.check : Icons.close,
          color: isChecked ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
