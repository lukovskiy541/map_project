import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/message.dart';

class SocketService {
  static const String _serverUrl = 'http://localhost:5000';
  late IO.Socket _socket;

  void connect() {
    _socket = IO.io(
      _serverUrl,
      IO.OptionBuilder()
        .setTransports(['websocket', 'polling'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .build(),
    );

    _setupEventHandlers();
  }

  void _setupEventHandlers() {
    _socket.onConnect((_) {
      print('Connected to Socket.IO server');
      print('Socket ID: ${_socket.id}');
    });
    
    _socket.onDisconnect((_) => print('Disconnected from Socket.IO server'));
    _socket.onConnectError((err) => print('Connect error: $err'));
    _socket.onError((err) => print('Error: $err'));
    
    // Listen for reconnection events
    _socket.on('reconnect', (_) => print('Reconnected to Socket.IO server'));
    _socket.on('reconnect_error', (err) => print('Reconnection error: $err'));
    _socket.on('reconnect_attempt', (_) => print('Attempting to reconnect...'));
  }

  void onNewMessage(Function(Message) onMessage) {
    _socket.on('new_message', (data) {
      print('Received new_message event: $data'); // Debug log
      try {
        final message = Message.fromJson(Map<String, dynamic>.from(data));
        onMessage(message);
      } catch (e) {
        print('Error parsing message: $e');
        print('Raw data: $data');
      }
    });
  }

  bool isConnected() => _socket.connected;

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