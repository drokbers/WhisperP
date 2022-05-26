import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

import '../consts/index.dart';
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
            Navigator.pushReplacementNamed(context, RouteNames.messagingPage);
          }),
        ],
      );
    },
    RouteNames.profile: (_) {
      return ProfileScreen(
        providerConfigs: _providerConfigs,
        appBar: AppBar(title: const Text(Str.profilePageTitle)),
        actions: [
          SignedOutAction((context) {
            Navigator.pushReplacementNamed(context, RouteNames.signIn);
          }),
        ],
      );
    },
    RouteNames.messagingPage: (_) => const MessagesPage(),
  };
}
