class Message {
  final String channelName;
  final String messageText;
  final int channelId;
  final int messageId;

  Message({
    required this.channelName,
    required this.messageText,
    required this.channelId,
    required this.messageId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      channelName: json['channel_name'] ?? 'Unknown Channel',
      messageText: json['message_text'] ?? 'No text',
      channelId: json['channel_id'] ?? 0,
      messageId: json['message_id'] ?? 0,
    );
  }
}