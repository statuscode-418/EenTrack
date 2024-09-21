import 'package:eentrack/screen/homescreen/home_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_bar_code/qr/src/qr_code.dart';

class DetailsQrView extends StatelessWidget {
  const DetailsQrView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeScreenVM>();
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: QRCode(
        data: vm.userQrString,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    ));
  }
}
