import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.messageText),
      subtitle: Text(message.channelName),
    );
  }
}