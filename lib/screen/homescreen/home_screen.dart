import 'package:eentrack/models/user_model.dart';
import 'package:eentrack/screen/homescreen/details_qr_view.dart';
import 'package:eentrack/screen/homescreen/home_screen_vm.dart';
import 'package:eentrack/screen/shared/show_snackbar.dart';
import 'package:eentrack/services/dbservice/db_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_meeting_view.dart';
import 'profile_view.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  final DBModel dbprovider;
  final String? error;
  final bool isLoading;

  const HomeScreen({
    super.key,
    required this.user,
    required this.dbprovider,
    this.error,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(context, "Something Went wrong");
      });
      return const Center(
        child: Text("Something Went Wrong"),
      );
    }
    return ChangeNotifierProvider(
      create: (context) => HomeScreenVM(
        context,
        user: user,
        db: dbprovider,
      ),
      child: const HomeScreenConsumer(),
    );
  }
}

class HomeScreenConsumer extends StatelessWidget {
  const HomeScreenConsumer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var vm = context.watch<HomeScreenVM>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('EenTrack'),
        actions: [
          IconButton(
            onPressed: vm.showSettings, //_onLogout(context),
            icon: Image.asset('assets/logo.png'),
          )
        ],
      ),
      body: PageView(
        controller: vm.homePageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DetailsQrView(),
          ProfileView(),
          NewMeetingView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        currentIndex: vm.pageNo,
        useLegacyColorScheme: false,
        type: BottomNavigationBarType.shifting,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            label: 'QR',
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
          vm.switchPage(index);
        },
      ),
    );
  }
}
