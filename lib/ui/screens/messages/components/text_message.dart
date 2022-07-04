import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:whisperp/extensions/date_time_ext.dart';
import 'package:whisperp/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:whisperp/models/user_model.dart';

import '../../../../consts/index.dart';
import '../../../constants.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isSender = message.senderId == FirebaseAuth.instance.currentUser?.uid;
    final user = Hive.box<UserModel>(BoxNames.users).get(message.senderId)!;

    return Row(
      mainAxisAlignment:
          isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSender)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 4.0),
            child: CircleAvatar(
              radius: 14,
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.photoURL,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
        Expanded(
          child: Align(
            alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(
                right: kDefaultPadding * 0.75,
                top: kDefaultPadding / 2,
                bottom: kDefaultPadding / 2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: kDefaultPadding * 0.75,
                vertical: kDefaultPadding / 2,
              ),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(isSender ? 1 : 0.2),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(
                    isSender ? 0 : kDefaultPadding,
                  ),
                  topLeft: Radius.circular(
                    !isSender ? 0 : kDefaultPadding,
                  ),
                  bottomLeft: const Radius.circular(kDefaultPadding),
                  bottomRight: const Radius.circular(kDefaultPadding),
                ),
              ),
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isSender
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText1!.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${message.timestamp.timeDifference} ago",
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
