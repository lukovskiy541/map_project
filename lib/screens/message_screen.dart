import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../models/message.dart';
import '../widgets/message_list.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final SocketService _socketService = SocketService();
  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _initializeSocket();
  }

  void _initializeSocket() {
    _socketService.connect();
    _socketService.onNewMessage((message) {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  Future<void> _onRefresh() async {
    await _socketService.reconnect();
    return Future.delayed(const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Real-Time Messages'),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: MessageList(messages: messages),
      ),
    );
  }
}