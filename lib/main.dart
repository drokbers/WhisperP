import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'consts/index.dart';
import 'firebase_options.dart';
import 'messaging_ui/theme.dart';
import 'services/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await Hive.openBox(BoxNames.settings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isSkipped =
        Hive.box(BoxNames.settings).get('is-skipped', defaultValue: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      initialRoute: isSkipped
          ? FirebaseAuth.instance.currentUser == null
              ? RouteNames.signInOrSignUpScreen
              : RouteNames.chatScreen
          : RouteNames.welcomeScreen,
      routes: AppRoutes.routes,
    );
  }
}
