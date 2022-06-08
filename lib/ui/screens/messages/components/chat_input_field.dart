import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whisperp/models/chat_message.dart';

import '../../../constants.dart';

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key, required this.messagesDocId});

  final String messagesDocId;

  @override
  Widget build(BuildContext context) {
    final textEditCtrlr = TextEditingController(text: "");

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kDefaultPadding,
        vertical: kDefaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 32,
            color: const Color(0xFF087949).withOpacity(0.08),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(Icons.mic, color: kPrimaryColor),
            const SizedBox(width: kDefaultPadding),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textEditCtrlr,
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: kDefaultPadding / 4),
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .color!
                          .withOpacity(0.64),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                if (textEditCtrlr.text.isNotEmpty) {
                  final message = ChatMessage(
                    text: textEditCtrlr.text,
                    senderId: FirebaseAuth.instance.currentUser!.uid,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.notview,
                    timestamp: DateTime.now(),
                  );

                  textEditCtrlr.text = "";

                  FirebaseFirestore.instance
                      .collection('messages')
                      .doc(messagesDocId)
                      .collection('messages')
                      .add({
                    ...message.toMap(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                }
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
