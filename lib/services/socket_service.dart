import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';

class SocketService {
  static const String _serverUrl =
      'ws://localhost:5000';
  late IO.Socket _socket;

  void connect() {
    _socket = IO.io(_serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _setupEventHandlers();
  }

  void _setupEventHandlers() {
    _socket.onConnect((_) => print('Connected to Socket.IO server'));
    _socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));
    _socket.onConnectError((err) => print('Connect error: $err'));
    _socket.onError((err) => print('Error: $err'));
  }

  void onNewMessage(Function(Message) onMessage) {
    print("new message recieved");
    _socket.on('new_message', (data) {
      final message = Message.fromJson(Map<String, dynamic>.from(data));
      onMessage(message);
    });
  }

  Future<void> reconnect() async {
    disconnect();
    connect();
  }

  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }
}
