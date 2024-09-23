import 'package:eentrack/screen/meeting_details_screen/components/participant_card.dart';
import 'package:eentrack/screen/scanning_screen/scanning_screen_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanningScreenView extends StatelessWidget {
  const ScanningScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<ScanningScreenVm>();
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.meeting.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
                child: MobileScanner(
                  controller: vm.scannerController,
                  onDetect: vm.onDetectBarcode,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              children: vm.checkPoints
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(e.title),
                        selected: vm.selectedCheckPoint == e,
                        onSelected: (selected) {
                          if (selected) {
                            vm.onCheckPointSelected(e);
                          } else {
                            vm.onCheckPointSelected(null);
                          }
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: vm.participants.length,
                itemBuilder: (context, i) => ParticipantCard(
                  participant: vm.participants[i],
                  checkpoints: vm.checkPoints,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/participant',
                      arguments: {
                        'participant': vm.participants[i],
                        'checkpoints': vm.checkPoints,
                        'db': vm.db,
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
