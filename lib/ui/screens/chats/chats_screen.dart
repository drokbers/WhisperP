import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/constants.dart';
import 'package:whisperp/services/cache_users.dart';

import '../../../services/firestore_user_registeration.dart';
import 'components/body.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late final StreamSubscription? _userChanges;

  int _selectedIndex = 1;

  @override
  void initState() {
    _userChanges = FirebaseAuth.instance.userChanges().listen((event) {
      FirestoreUserRegisteration().checkUserIfRegisterated(event);
    });

    CacheUsersService.getAndSaveUsers();

    super.initState();
  }

  @override
  void dispose() {
    _userChanges?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Chats"),
        actions: [
          HiveListener(
            box: Hive.box(BoxNames.settings),
            keys: const ['dark-theme'],
            builder: (box) {
              final isDarkTheme =
                  box.get('dark-theme', defaultValue: false) as bool;
              return IconButton(
                icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  box.put('dark-theme', !isDarkTheme);
                },
              );
            },
          ),
        ],
      ),
      body: Body(pageIndex: _selectedIndex),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.searchScreen);
        },
        backgroundColor: kPrimaryColor,
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.messenger), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              backgroundImage: AssetImage("assets/images/user_2.png"),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
