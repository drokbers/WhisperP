import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:whisperp/ui/screens/chats/chats_screen.dart';

import '../../../consts/index.dart';
import '../../../services/cache_users.dart';
import '../../../services/firestore_user_registeration.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final StreamSubscription? _userChanges;
  final _tabs = const ["Chats", "Calls", "Profile"];

  int _selectedIndex = 0;

  @override
  void initState() {
    _userChanges = FirebaseAuth.instance.userChanges().listen((event) {
      FirestoreUserRegisteration().checkUserIfRegisterated(event);
    });

    CacheUsersService.getAndSaveUsers();

    super.initState();

    debugPrint( "CurrentUser photoUrl: ${FirebaseAuth.instance.currentUser!.photoURL}");
    
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
        title: Text(_tabs[_selectedIndex]),
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
      body: () {
        switch (_selectedIndex) {
          case 0:
            return const ChatScreen();
          case 2:
            return ProfileScreen(
              providerConfigs: const [EmailProviderConfiguration()],
              actions: [
                SignedOutAction((context) {
                  Navigator.pushReplacementNamed(
                    context,
                    RouteNames.signInOrSignUpScreen,
                  );
                }),
              ],
            );
          default:
            return const Center(child: Text("Not ready"));
        }
      }(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (value) {
          _selectedIndex = value;
          setState(() {});
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.messenger), label: "Chats"),
          const BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 14,
              child: ClipOval(
                  child: CachedNetworkImage(
                imageUrl: FirebaseAuth.instance.currentUser!.photoURL ??
                    Str.dummyProfilePhotoUrl,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
              )),
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
