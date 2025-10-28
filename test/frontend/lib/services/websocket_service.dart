import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../utils/platform_helper.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  
  WebSocketService._internal();
  
  bool get isConnected => _isConnected;
  
  Future<void> connect() async {
    if (_isConnected) return;
    
    try {
      final baseUrl = PlatformHelper.getWebSocketUrl();
      _channel = WebSocketChannel.connect(
        Uri.parse('$baseUrl/ws'),
      );
      
      _isConnected = true;
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _handleMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket disconnected');
          _isConnected = false;
        },
      );
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      _isConnected = false;
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _channel = null;
  }
  
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected');
      return;
    }
    
    _channel!.sink.add(json.encode(data));
  }
  
  void _handleMessage(Map<String, dynamic> data) {
    // Handle incoming WebSocket messages
    print('WebSocket message: $data');
    // TODO: Notify listeners based on message type
  }
  
  // Stream listener for specific events
  Stream<String> listenToEvent(String eventType) {
    if (_channel == null) return const Stream.empty();
    
    return _channel!.stream.map((message) {
      try {
        final data = json.decode(message);
        if (data['type'] == eventType) {
          return message as String;
        }
        return '';
      } catch (e) {
        return '';
      }
    }).where((message) => message.isNotEmpty) as Stream<String>;
  }
}

