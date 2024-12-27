import 'package:flutter/material.dart';
import '../models/message.dart';
import 'message_tile.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;

  const MessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return messages.isEmpty
        ? const Center(child: Text('No messages yet'))
        : ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) => MessageTile(message: messages[index]),
          );
  }
}