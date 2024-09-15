import 'package:flutter/material.dart';

Future<DateTime?> showDateTimePicker(BuildContext context, String title) async {
  final date = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  if (date == null) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}
