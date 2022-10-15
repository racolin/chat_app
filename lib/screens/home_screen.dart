import 'dart:io';
import 'dart:math';

import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/widgets/people_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../widgets/chat_list_widget.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;
  var bodies = [];

  @override
  void initState() {
    FirebaseMessaging.onMessage.listen((event) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: const Text('data')));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    bodies.add(ChatListWidget(uid: uid));
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Home' : 'Connect friends'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit profile',
                  child: ListTile(
                    title: Text('Edit profile'),
                    leading: Icon(Icons.account_circle_outlined),
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    title: Text('Log out'),
                    leading: Icon(Icons.logout),
                  ),
                ),
              ];
            },
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  FirebaseAuth.instance.signOut();
                  break;
                case 'edit profile':
                  Navigator.of(context).pushNamed(ProfileScreen.route);
                  break;
              }
            },
          ),
        ],
      ),
      body:
          _currentIndex == 1 ? const PeopleWidget() : ChatListWidget(uid: uid),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        color: Colors.amber,
        child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _currentIndex,
            onTap: (index) {
              if (index == 1 && bodies.length < 2) {
                bodies.add(const PeopleWidget());
              }
              setState(() {
                _currentIndex = index;
              });
            },
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.white,
            items: const [
              BottomNavigationBarItem(
                label: 'Home',
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: 'Connect friends',
                icon: Icon(Icons.group),
              )
            ]),
      ),
    );
  }
}
