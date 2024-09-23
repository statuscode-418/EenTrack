import 'package:eentrack/models/checkpoint_model.dart';
import 'package:eentrack/models/participant_model.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final dateFormat = DateFormat('hh:mm:ss a, dd-MM-yyyy');

  bool init = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!init) {
      final args = ModalRoute.of(context)!.settings.arguments as Map;
      participant = args['participant'];
      checkPoints = args['checkpoints'];
      popOnChecked = args['pop_on_checked'] ?? false;
      db = args['db'];
      init = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(participant.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                ...participant.data.entries.map(
                  (e) => ParticipantDetailsTile(
                    title: e.key,
                    value: e.value,
                  ),
                ),
                ...checkPoints.where((e) => participant.isChecked(e.id)).map(
                      (e) => ParticipantDetailsTile(
                        title: e.title,
                        value: dateFormat.format(participant.checkPoints[e.id]!),
                      ),
                    ),
              ],
            ),
          ),
          Wrap(
            children: checkPoints
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CheckpointChip(
                      title: e.title,
                      isChecked: participant.isChecked(e.id),
                      onTap: () async {
                        if (participant.isChecked(e.id)) {
                          participant.unmarkCheckPoint(e.id);
                          await db.updateParticipant(participant);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${participant.name} | ${e.title} unchechecked'),
                            ),
                          );
                        } else {
                          participant.markCheckPoint(e.id);
                          await db.updateParticipant(participant);
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

class ParticipantDetailsTile extends StatelessWidget {
  final String title;
  final dynamic value;

  const ParticipantDetailsTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
