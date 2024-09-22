import 'package:eentrack/models/checkpoint_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

Future<CheckpointModel?> showAddCheckpointDialog(
  BuildContext context,
  String mid,
  String uid,
) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AddCheckpoint(
        mid: mid,
        uid: uid,
        onCheckpointCreated: (checkpoint) {
          Navigator.of(context).pop(checkpoint);
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      );
    },
  );
}

class AddCheckpoint extends StatefulWidget {
  final String mid;
  final String uid;
  final void Function(CheckpointModel) onCheckpointCreated;
  final VoidCallback onCancel;
  const AddCheckpoint({
    super.key,
    required this.mid,
    required this.uid,
    required this.onCheckpointCreated,
    required this.onCancel,
  });

  @override
  State<AddCheckpoint> createState() => _AddCheckpointState();
}

class _AddCheckpointState extends State<AddCheckpoint> {
  DateTime? date;
  final format = DateFormat("dd/MM/yyyy HH:mm");
  String name = '';

  void pickDateTime() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (selectedDate == null) return;
    if (!mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime == null) return;
    date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    setState(() {});
  }

  void createCheckpoint() {
    if (name.isEmpty || date == null) {
      return;
    }
    var id = const Uuid().v4();
    var checkpoint = CheckpointModel(
      id: id,
      mid: widget.mid,
      uid: widget.uid,
      title: name,
      time: date!,
    );
    widget.onCheckpointCreated(checkpoint);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Create Checkpoint"),
      contentPadding: const EdgeInsets.all(20),
      children: [
        TextField(
          onChanged: (e) {
            name = e;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            hintText: "Enter name of checkpoint",
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          onPressed: pickDateTime,
          child: Text(date == null ? "Select Date" : format.format(date!)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: createCheckpoint,
              child: const Text("Create"),
            ),
          ],
        ),
      ],
    );
  }
}
