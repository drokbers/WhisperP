class MessageModel {
  late final String senderImage;
  late final DateTime timestamp;
  late final String senderId;
  late final String receiverId;
  late final String senderName;
  late final String message;
  late final bool read;
  late final List relations;

  MessageModel({
    required this.senderImage,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.message,
    required this.read,
    required this.relations,
  });

  MessageModel.fromJson(Map<String, dynamic> json) {
    senderImage = json['sender_image']??"https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png";
    timestamp = json['timestamp'].toDate();

    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    senderName = json['sender_name']??"unknown";
    message = json['message'];
    read = json['read'] ?? false;
    relations = json['relations'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sender_image'] = senderImage;
    data['timestamp'] = timestamp;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['sender_name'] = senderName;
    data['message'] = message;
    data['read'] = read;
    data['relations'] = relations;
    return data;
  }
}
