import 'package:flutter/material.dart';
import 'package:whisperp/consts/index.dart';
import 'package:whisperp/ui/constants.dart';

import '../../models/chat.dart';
import 'components/chat_card.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: chatsData.length,
        itemBuilder: (context, index) => ChatCard(
          chat: chatsData[index],
          press: () => Navigator.pushNamed(
            context,
            RouteNames.messagesScreen,
          ),
        ),
      ),
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
    );
  }
}
