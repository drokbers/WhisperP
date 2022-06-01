import 'package:flutter/material.dart';
import 'package:whisperp/models/message_model.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({Key? key, required this.messageModel}) : super(key: key);
  final MessageModel messageModel;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.person),
          Column(),
        ],
      ),
    );
  }
}
