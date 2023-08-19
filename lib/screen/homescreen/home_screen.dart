import 'package:flutter/material.dart';
import 'package:project_f/screen/homescreen/newmeeting_screen.dart';
import 'package:project_f/screen/homescreen/profile_screen.dart';
import 'package:project_f/screen/homescreen/scanner_screen.dart';

import '../authscreens/shared/custombuttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<String> _appBarTitles = ['Profile', 'Scanner', 'New Meeting'];

  final List<Widget> _screens = [
    const ProfileScreen(),
    const ScannerScreen(),
    const NewMeetingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            _appBarTitles[_currentIndex],
            style: const TextStyle(
              color: Colors.cyan,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/logo_rounded.png',
            width: 40,
            height: 40,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomIconButton(
              onPressed: () {},
              icon: Icons.logout,
              iconColor: Colors.white,
              iconSize: 40,
            ),
          )
        ],
      ),
      // body: Navigator(
      //   initialRoute: '/',
      //   onGenerateRoute: (RouteSettings settings) {
      //     return MaterialPageRoute(
      //       builder: (BuildContext context) {
      //         return _screens[_currentIndex];
      //       },
      //     );
      //   },
      // ),
      body: Center(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(
          top: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        )),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          iconSize: 50,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_rounded),
              label: '',
            )
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
