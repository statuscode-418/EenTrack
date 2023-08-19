import 'package:flutter/material.dart';
import 'package:project_f/screen/authscreens/shared/custombuttons.dart';

class NewMeetingScreen extends StatelessWidget {
  const NewMeetingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Align(
              alignment: Alignment.topRight,
              child: CustomIconButton(
                onPressed: () {},
                icon: Icons.history,
                iconColor: Colors.white,
                iconSize: 40,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: CustomElevatedButton(
                buttonText: 'New Meeting',
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
    );
  }
}
