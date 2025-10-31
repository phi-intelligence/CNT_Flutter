import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  
  IO.Socket? _socket;
  bool _isConnected = false;
  
  WebSocketService._internal();
  
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    if (_isConnected) return;
    try {
      final url = 'http://10.0.2.2:8002';
      _socket = IO.io(url, <String, dynamic>{
        'path': '/socket.io/',
        'transports': ['websocket'],
        'autoConnect': true,
        'forceNew': true,
      });

      _socket!.on('connect', (_) {
        _isConnected = true;
      });
      _socket!.on('disconnect', (_) {
        _isConnected = false;
      });
      _socket!.on('message', (data) {
        try {
          if (data is String) {
            _handleMessage(json.decode(data));
          } else if (data is Map<String, dynamic>) {
            _handleMessage(data);
          }
        } catch (_) {}
      });
      _socket!.on('error', (_) {
        _isConnected = false;
      });
    } catch (_) {
      _isConnected = false;
    }
  }
  
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    _socket = null;
  }
  
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _socket == null) {
      print('WebSocket not connected - message not sent');
      return;
    }
    
    try {
      _socket!.emit('message', data);
    } catch (e) {
      print('Error sending WebSocket message: $e');
      _isConnected = false;
      _socket = null;
    }
  }
  
  void _handleMessage(Map<String, dynamic> data) {
    // Handle incoming WebSocket messages
    print('WebSocket message: $data');
    // TODO: Notify listeners based on message type
  }
  
  // Stream listener for specific events
  Stream<String> listenToEvent(String eventType) {
    if (_socket == null) return const Stream.empty();
    return const Stream.empty();
  }
}

