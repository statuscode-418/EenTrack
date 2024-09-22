import 'package:eentrack/screen/meeting_details_screen/meeting_details_screen_vm.dart';
import 'package:eentrack/screen/meeting_details_screen/meeting_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeetingDetailsScreen extends StatelessWidget {
  const MeetingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final user = args['user'];
    final meeting = args['meeting'];
    final db = args['db'];
    return ChangeNotifierProvider(
      create: (context) =>
          MeetingDetailsScreenVM(context, user: user, meeting: meeting, db: db),
      child: const MeetingDetailsView(),
    );
  }
}
