import 'package:flutter/material.dart';
import 'package:project_f/screen/authscreens/shared/customcontainer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/profile_dummy.jpg'),
              radius: 60,
            ),
            SizedBox(
              height: 20,
            ),
            Text('Hello Robert!'),
            SizedBox(
              height: 20,
            ),
            CustomContainer(
              text: 'J Robert Openheimer',
            ),
            SizedBox(
              height: 20,
            ),
            CustomContainer(
              text: 'Atomic Science Department',
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomContainer(
                    text: 'Roll No 69',
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomContainer(
                    text: 'Sem 4',
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            CustomContainer(
              text: 'FuckYouFuckoff@github.com',
            ),
            SizedBox(
              height: 20,
            ),
            CustomContainer(
              text: 'FuckYouFuckoff@linkedin.com',
            ),
          ],
        ),
      ),
    );
  }
}
