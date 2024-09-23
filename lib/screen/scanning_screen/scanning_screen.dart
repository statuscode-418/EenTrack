import 'package:eentrack/screen/scanning_screen/scanning_screen_view.dart';
import 'package:eentrack/screen/scanning_screen/scanning_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    var db = args['db'];
    var meeting = args['meeting'];
    return ChangeNotifierProvider(
      create: (context) => ScanningScreenVm(
        context,
        db: db,
        meeting: meeting,
      ),
      child: const ScanningScreenView(),
    );
  }
}

