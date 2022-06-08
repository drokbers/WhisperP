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
