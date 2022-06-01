import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:whisperp/messaging_ui/screens/signinOrSignUp/signin_or_signup_screen.dart';
import 'package:whisperp/messaging_ui/screens/welcome/welcome_screen.dart';

import '../consts/index.dart';
import '../messaging_ui/screens/chats/chats_screen.dart';
import '../ui/messages_page.dart';
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
            Navigator.pushReplacementNamed(context, RouteNames.chatScreen);
          }),
        ],
      );
    },
    RouteNames.register: (_) {
      return const RegisterScreen(providerConfigs: _providerConfigs);
    },
    RouteNames.messagingPage: (_) => const MessagesPage(),
    RouteNames.welcomeScreen: (_) => const WelcomeScreen(),
    RouteNames.signInOrSignUpScreen: (_) => const SigninOrSignupScreen(),
    RouteNames.chatScreen: (_) => const ChatsScreen(),
  };
}
