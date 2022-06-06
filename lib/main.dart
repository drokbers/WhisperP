import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_listener/hive_listener.dart';
import 'package:whisperp/models/user_model.dart';

import 'consts/index.dart';
import 'firebase_options.dart';
import 'ui/theme.dart';
import 'services/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await Hive.openBox(BoxNames.settings);

  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<UserModel>(BoxNames.users);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isSkipped = Hive.box(BoxNames.settings).get(
      'is-skipped',
      defaultValue: false,
    );

    return HiveListener(
      box: Hive.box(BoxNames.settings),
      keys: const ['dark-theme'],
      builder: (box) {
        final isDarkTheme = box.get('dark-theme', defaultValue: false) as bool;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: isDarkTheme ? ThemeMode.dark : ThemeMode.light,
          theme: lightThemeData(context),
          darkTheme: darkThemeData(context),
          initialRoute: isSkipped
              ? FirebaseAuth.instance.currentUser == null
                  ? RouteNames.signInOrSignUpScreen
                  : RouteNames.chatScreen
              : RouteNames.welcomeScreen,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
