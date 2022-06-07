import 'package:cached_network_image_builder/cached_network_image_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:whisperp/models/user_model.dart';
import 'package:whisperp/ui/constants.dart';
import 'package:flutter/material.dart';

import '../../models/chat_message.dart';
import 'components/chat_input_field.dart';
import 'components/message.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as UserModel;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const BackButton(),
            CircleAvatar(
              child: ClipOval(
                child: kIsWeb
                    ? Image.network(user.photoURL)
                    : CachedNetworkImageBuilder(
                        url: user.photoURL,
                        builder: (image) {
                          return Image.file(image);
                        },
                      ),
              ),
            ),
            const SizedBox(width: kDefaultPadding * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                const Text(
                  "Online",
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_phone),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () {},
          ),
          const SizedBox(width: kDefaultPadding / 2),
        ],
      ),
      body: Column(
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
          const ChatInputField(),
        ],
      ),
    );
  }
}
