import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatMessageType { text, image }

enum MessageStatus { notSent, notview, viewed }

class ChatMessage {
  const ChatMessage({
    required this.senderId,
    required this.text,
    required this.messageType,
    required this.messageStatus,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map map) {
    return ChatMessage(
      senderId: map['senderId'],
      text: map['text'],
      messageType: ChatMessageType.values
          .where((e) => e.name == map['messageType'])
          .first,
      messageStatus: MessageStatus.values
          .where((e) => e.name == map['messageStatus'])
          .first,
      timestamp: (map['timestamp'] is Timestamp
              ? map['timestamp'].toDate()
              : map['timestamp']) ??
          DateTime.now(),
    );
  }

  final String senderId;
  final String text;
  final ChatMessageType messageType;
  final MessageStatus messageStatus;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'messageType': messageType.name,
      'messageStatus': messageStatus.name,
      'timestamp': timestamp,
    };
  }
}
