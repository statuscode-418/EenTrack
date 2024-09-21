import 'package:flutter/material.dart';

class AppVM extends ChangeNotifier {
  final BuildContext context;

  AppVM(this.context);

  void safeNotify() {
    if (!context.mounted) return;
    notifyListeners();
  }

  void safeShowSnackbar(String message, {bool error = false}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }
}
