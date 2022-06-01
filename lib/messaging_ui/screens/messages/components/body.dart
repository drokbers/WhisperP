import 'package:whisperp/messaging_ui/constants.dart';
<<<<<<< HEAD
import 'package:whisperp/messaging_ui/models/chat_message.dart';
=======
import 'package:whisperp/messaging_ui/models/ChatMessage.dart';
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
import 'package:flutter/material.dart';

import 'chat_input_field.dart';
import 'message.dart';

class Body extends StatelessWidget {
<<<<<<< HEAD
  const Body({Key? key}) : super(key: key);

=======
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: ListView.builder(
              itemCount: demeChatMessages.length,
              itemBuilder: (context, index) =>
                  Message(message: demeChatMessages[index]),
            ),
          ),
        ),
<<<<<<< HEAD
        const ChatInputField(),
=======
        ChatInputField(),
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
      ],
    );
  }
}
