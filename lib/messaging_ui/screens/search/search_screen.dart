import 'package:flutter/material.dart';

import '../../models/chat.dart';
import '../chats/components/chat_card.dart';
import '../messages/message_screen.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final searchText = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 48,
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(),
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => searchText.value = v,
          ),
        ),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: searchText,
        builder: (_, value, __) {
          final resultList = value.isEmpty
              ? []
              : chatsData.where((e) => e.toString().contains(value)).toList();

          return ListView.builder(
            itemCount: resultList.length,
            itemBuilder: (context, index) => ChatCard(
              chat: resultList[index],
              press: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MessagesScreen(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
