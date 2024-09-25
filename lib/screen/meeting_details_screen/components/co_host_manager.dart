import 'package:eentrack/screen/meeting_details_screen/meeting_details_screen_vm.dart';
import 'package:flutter/material.dart';

class CoHostManager extends StatefulWidget {
  final MeetingDetailsScreenVM vm;
  const CoHostManager({
    super.key,
    required this.vm,
  });

  @override
  State<CoHostManager> createState() => _CoHostManagerState();
}

class _CoHostManagerState extends State<CoHostManager> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.vm.addListener(() {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Manage Co-Hosts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
              IconButton(
                onPressed: widget.vm.addCohost,
                icon: const Icon(Icons.add),
              )
            ],
          ),
          const Divider(
            height: 20,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, i) {
                var coHost = widget.vm.coHosts[i];
                return ListTile(
                  title: Text(coHost.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => widget.vm.removeCohost(coHost),
                  ),
                );
              },
              itemCount: widget.vm.coHosts.length,
            ),
          )
        ],
      ),
    );
  }
}

