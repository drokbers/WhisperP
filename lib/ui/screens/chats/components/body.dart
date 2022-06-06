import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/models/chat.dart';

import 'chat_card.dart';

class Body extends StatelessWidget {
  const Body({super.key, required this.pageIndex});

  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    return pageIndex == 2
        ? ProfileScreen(
            providerConfigs: const [EmailProviderConfiguration()],
            actions: [
              SignedOutAction((context) {
                Navigator.pushReplacementNamed(
                  context,
                  RouteNames.signInOrSignUpScreen,
                );
              }),
            ],
          )
        : ListView.builder(
            itemCount: chatsData.length,
            itemBuilder: (context, index) => ChatCard(
              chat: chatsData[index],
              press: () => Navigator.pushNamed(
                context,
                RouteNames.messagesScreen,
              ),
            ),
          );
  }
}
