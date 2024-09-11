// ignore_for_file: use_build_context_synchronously

import 'package:eentrack/models/attendee_model.dart';
import 'package:eentrack/models/meeting_model.dart';
import 'package:eentrack/screen/meeting_details_screen/components/attendee_sliver_list.dart';
import 'package:eentrack/screen/shared/multi_selection_switch.dart';
import 'package:eentrack/screen/shared/show_snackbar.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:eentrack/services/qr_service/qr_parser.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rxdart/rxdart.dart';

enum ScanType {
  entry,
  exit,
}

extension ScanTypeExtension on ScanType {
  String get name {
    switch (this) {
      case ScanType.entry:
        return 'Entry';
      case ScanType.exit:
        return 'Exit';
      default:
        return 'Unknown';
    }
  }
}

class ScanningScreen extends StatefulWidget {
  final Meeting meeting;
  final DBModel dbprovider;
  const ScanningScreen(
      {super.key, required this.meeting, required this.dbprovider});

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  late MobileScannerController _controller;
  late Stream<List<Attendee>> _addedAttendeeStream;
  late Stream<List<Attendee>> _leftAttendeeStream;
  late Stream<List<List<Attendee>>> _attendeeStream;
  var attendees = <Attendee>[];
  var addedAttendees = <Attendee>[];
  var leftAttendees = <Attendee>[];
  var scanType = ScanType.entry;

  DBModel get db => widget.dbprovider;

  List<Attendee> get filteredAttendees {
    switch (scanType) {
      case ScanType.entry:
        return addedAttendees;
      case ScanType.exit:
        return leftAttendees;
      default:
        return attendees;
    }
  }

  void _addAttendee(Attendee attendee) async {
    var index = attendees.indexWhere((element) => element.uid == attendee.uid);
    if (index == -1) {
      await db.addAttendee(widget.meeting.hostid, widget.meeting.id, attendee);
    } else {
      attendee = attendees[index];
    }
    if (mounted) {
      return;
    }
    switch (scanType) {
      case ScanType.entry:
        if (attendee.isPresent) {
          showSnackbar(context, 'Already Present', type: SnackbarType.error);
          return;
        }
        attendee.addedOn = DateTime.now();
        break;
      case ScanType.exit:
        if (attendee.isLeft) {
          showSnackbar(context, 'Already Left', type: SnackbarType.error);
          return;
        }
        attendee.leftOn = DateTime.now();
        break;
      default:
        break;
    }
    await db.updateAttendee(widget.meeting.hostid, widget.meeting.id, attendee);
    if (!context.mounted) {
      return;
    }
    showSnackbar(context, 'Attendee ${scanType.name}ed',
        type: SnackbarType.success);
  }

  void _onDetect(BarcodeCapture scan) {
    var codes = scan.barcodes;
    if (codes.isEmpty) {
      return;
    }
    for (var code in codes) {
      var raw = code.rawValue;
      if (raw == null) {
        continue;
      }
      var attendee = QrParser.parseAttendee(raw);
      if (attendee == null) {
        showSnackbar(context, 'Invalid QR Code', type: SnackbarType.error);
        continue;
      }
      try {
        _addAttendee(attendee);
      } catch (e) {
        showSnackbar(context, 'Something went wrong', type: SnackbarType.error);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _addedAttendeeStream =
        db.getAddedAttendees(widget.meeting.hostid, widget.meeting.id);
    _leftAttendeeStream =
        db.getLeftAttendees(widget.meeting.hostid, widget.meeting.id);
    _attendeeStream =
        CombineLatestStream.list([_addedAttendeeStream, _leftAttendeeStream]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 250,
              width: 250,
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MultiSelectionSwitch(
              lables: ScanType.values.map((e) => e.name).toList(),
              selectedIndex: ScanType.values.indexOf(scanType),
              onChanged: (index) {
                setState(() {
                  scanType = ScanType.values[index];
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder(
              stream: _attendeeStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                var data = snapshot.data as List<List<Attendee>>;
                addedAttendees = data[0];
                leftAttendees = data[1];
                attendees = addedAttendees + leftAttendees;
                return Expanded(
                    child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total: ${filteredAttendees.length}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(8.0),
                      sliver: AttendeeSliverList(
                        attendees: filteredAttendees,
                      ),
                    )
                  ],
                ));
              }),
        ],
      ),
    );
  }
}
