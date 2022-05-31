import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/messaging_ui/components/filled_outline_button.dart';
import 'package:whisperp/messaging_ui/constants.dart';
import 'package:whisperp/messaging_ui/models/Chat.dart';
import 'package:whisperp/messaging_ui/screens/messages/message_screen.dart';

import 'chat_card.dart';

class Body extends StatelessWidget {
  const Body({super.key, required this.pageIndex});

  final int pageIndex;
  @override
  Widget build(BuildContext context) {
    return pageIndex == 3
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
        : Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding,
                  0,
                  kDefaultPadding,
                  kDefaultPadding,
                ),
                color: kPrimaryColor,
                child: Row(
                  children: [
                    FillOutlineButton(
                      press: () {},
                      text: "Recent Message",
                    ),
                    const SizedBox(width: kDefaultPadding),
                    FillOutlineButton(
                      press: () {},
                      text: "Active",
                      isFilled: false,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatsData.length,
                  itemBuilder: (context, index) => ChatCard(
                    chat: chatsData[index],
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessagesScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
