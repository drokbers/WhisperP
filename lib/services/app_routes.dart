import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:whisperp/ui/screens/main/main_screen.dart';
import 'package:whisperp/ui/screens/search/search_screen.dart';
import 'package:whisperp/ui/screens/signinOrSignUp/signin_or_signup_screen.dart';
import 'package:whisperp/ui/screens/welcome/welcome_screen.dart';

import '../consts/index.dart';
import '../ui/screens/messages/messages_screen.dart';
import 'firestore_user_registeration.dart';

class AppRoutes {
  static const _providerConfigs = [EmailProviderConfiguration()];

  static final routes = {
    RouteNames.signIn: (_) {
      return SignInScreen(
        providerConfigs: _providerConfigs,
        actions: [
          AuthStateChangeAction<SignedIn>((context, state) {
            FirestoreUserRegisteration().checkUserIfRegisterated(state.user);
            Navigator.popUntil(context, (route) => route.isFirst);
            Navigator.pushReplacementNamed(context, RouteNames.mainScreen);
          }),
        ],
      );
    },
    RouteNames.register: (_) {
      return const RegisterScreen(providerConfigs: _providerConfigs);
    },
    RouteNames.messagesScreen: (_) => const MessagesScreen(),
    RouteNames.welcomeScreen: (_) => const WelcomeScreen(),
    RouteNames.signInOrSignUpScreen: (_) => const SigninOrSignupScreen(),
    RouteNames.mainScreen: (_) => const MainScreen(),
    RouteNames.searchScreen: (_) => SearchScreen(),
  };
}
