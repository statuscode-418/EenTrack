import 'package:eentrack/screen/meeting_details_screen/components/participant_card.dart';
import 'package:eentrack/screen/meeting_details_screen/components/participant_search_delegate.dart';
import 'package:eentrack/screen/meeting_details_screen/meeting_details_screen_vm.dart';
import 'package:eentrack/screen/upload_meeting_details/upload_meeting_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PopupMenu { export, cohost, delete }

extension PopupMenuExtension on PopupMenu {
  String get value {
    switch (this) {
      case PopupMenu.export:
        return 'Export';
      case PopupMenu.cohost:
        return 'Cohost';
      case PopupMenu.delete:
        return 'Delete';
    }
  }

  IconData get icon {
    switch (this) {
      case PopupMenu.export:
        return Icons.share;
      case PopupMenu.cohost:
        return Icons.person_add;
      case PopupMenu.delete:
        return Icons.delete;
    }
  }
}

class MeetingDetailsView extends StatelessWidget {
  const MeetingDetailsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<MeetingDetailsScreenVM>();
    return Scaffold(
      appBar: AppBar(
        title: Text(vm.meeting.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UploadMeetingDetailsScreen(
                      meetingId: vm.meeting.id,
                      dbProvider: vm.db,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.upload_file,
              )),
          IconButton(
            onPressed: () => showSearch(
              context: context,
              delegate: ParticipantSearchDelegate(
                  vm.participants, vm.checkpoints, (p) {
                Navigator.of(context).pushNamed(
                  '/meeting/participant',
                  arguments: {
                    'participant': p,
                    'checkpoints': vm.checkpoints,
                    'db': vm.db,
                  },
                );
              }),
            ),
            icon: const Icon(Icons.search),
          ),
          if (vm.meeting.isHost)
            PopupMenuButton(
              itemBuilder: (context) => PopupMenu.values
                  .map((e) => PopupMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Icon(e.icon),
                            const SizedBox(width: 10),
                            Text(e.value),
                          ],
                        ),
                      ))
                  .toList(),
              onSelected: (PopupMenu result) {
                switch (result) {
                  case PopupMenu.export:
                    vm.shareDetails();
                    break;
                  case PopupMenu.cohost:
                    vm.manageCoHosts();
                    break;
                  case PopupMenu.delete:
                    vm.deleteMeeting();
                    break;
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomScrollView(
          slivers: <Widget>[
            if (vm.loading)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: Wrap(
                children: [
                  ...vm.checkpoints.map(
                    (c) => GestureDetector(
                      onLongPress: () => vm.deleteCheckpoint(c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChoiceChip(
                          label: Text(c.title),
                          selected: vm.checkpointFilter == c,
                          onSelected: (selected) {
                            if (selected) {
                              vm.toggleCheckpointFilter(c);
                            } else {
                              vm.toggleCheckpointFilter(null);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: vm.createCheckpoint,
                      icon: const Icon(Icons.add)),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Total: ${vm.participants.length}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final participant = vm.participants[index];
                  return ParticipantCard(
                      participant: participant,
                      checkpoints: vm.checkpoints,
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/meeting/participant',
                          arguments: {
                            'participant': participant,
                            'checkpoints': vm.checkpoints,
                            'db': vm.db,
                          },
                        );
                      });
                },
                childCount: vm.participants.length,
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(
            '/scan',
            arguments: {'meeting': vm.meeting, 'db': vm.db},
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
