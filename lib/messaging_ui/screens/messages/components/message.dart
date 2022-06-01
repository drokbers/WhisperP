<<<<<<< HEAD
import 'package:whisperp/messaging_ui/models/chat_message.dart';
=======
import 'package:whisperp/messaging_ui/models/ChatMessage.dart';
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'audio_message.dart';
import 'text_message.dart';
import 'video_message.dart';

class Message extends StatelessWidget {
  const Message({
    Key? key,
    required this.message,
  }) : super(key: key);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    Widget messageContaint(ChatMessage message) {
      switch (message.messageType) {
        case ChatMessageType.text:
          return TextMessage(message: message);
        case ChatMessageType.audio:
          return AudioMessage(message: message);
        case ChatMessageType.video:
<<<<<<< HEAD
          return const VideoMessage();
=======
          return VideoMessage();
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: kDefaultPadding),
      child: Row(
        mainAxisAlignment:
            message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSender) ...[
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage("assets/images/user_2.png"),
            ),
            const SizedBox(width: kDefaultPadding / 2),
          ],
          messageContaint(message),
          if (message.isSender) MessageStatusDot(status: message.messageStatus)
        ],
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({Key? key, this.status}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
<<<<<<< HEAD
        case MessageStatus.notSent:
          return kErrorColor;
        case MessageStatus.notview:
=======
        case MessageStatus.not_sent:
          return kErrorColor;
        case MessageStatus.not_view:
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
          return Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return kPrimaryColor;
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: kDefaultPadding / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
<<<<<<< HEAD
        status == MessageStatus.notSent ? Icons.close : Icons.done,
=======
        status == MessageStatus.not_sent ? Icons.close : Icons.done,
>>>>>>> 329fe534ffdd540f43b1d7bd2f94966192b6d3e7
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
