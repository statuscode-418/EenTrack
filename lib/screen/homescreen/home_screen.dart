import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/homescreen/edit_profile_screen.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/authbloc/auth_events.dart';
import '../../bloc/authbloc/authbloc.dart';
import '../dialog/alart_dialog.dart';
import 'newmeeting_view.dart';
import 'profile_view.dart';
import 'scanner_view.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  final DBModel dbprovider;
  final String? error;
  final bool isLoading;
  HomeScreen({
    Key? key,
    this.isLoading = false,
    this.error,
    required this.user,
    required this.dbprovider,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;

  late final List<String> _appBarTitles;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    if (widget.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.error!),
          ),
        );
      });
    }

    _screens = [
      ScannerView(
        user: widget.user,
        dbprovider: widget.dbprovider,
      ),
      ProfileView(
        user: widget.user,
      ),
      NewMeetingView(
        user: widget.user,
        dbprovider: widget.dbprovider,
      ),
    ];
    _appBarTitles = [
      'Scanner',
      'Profile',
      'Meetings',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _appBarTitles[_currentIndex],
          style: const TextStyle(),
        ),
        centerTitle: true, // No need of center widget
        leading: Image.asset(
          'assets/logo.png',
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                  ),
                ),
                const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit Profile'),
                    )),
              ];
            },
            onSelected: (value) {
              if (value == 'logout') {
                showAlartDialog('Logout', 'You sure want to logout?', context)
                    .then((value) {
                  if (value == Option.ok) {
                    BlocProvider.of<AuthBloc>(context).add(AuthEventLogout());
                  }
                });
              } else if (value == 'edit') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        EditProfileScreen(user: widget.user)));
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: _currentIndex,
        useLegacyColorScheme: false,
        type: BottomNavigationBarType.shifting,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'Join Meeting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_rounded),
            label: 'Meetings',
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
