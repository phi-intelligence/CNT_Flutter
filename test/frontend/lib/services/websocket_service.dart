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
      final uri = Uri.parse('$baseUrl/ws');
      
      // WebSocketChannel.connect() is lazy - it doesn't connect until stream is accessed
      // Create the channel but don't set connected yet
      WebSocketChannel? channel;
      try {
        channel = WebSocketChannel.connect(uri);
      } catch (e) {
        print('Failed to create WebSocket channel: $e');
        _isConnected = false;
        _channel = null;
        return;
      }
      
      // Try to set up listeners with error handling
      // Accessing the stream may trigger immediate connection and throw synchronously
      try {
        // Set up listener - this may trigger connection immediately
        final subscription = channel.stream.listen(
          (message) {
            try {
              if (message is String) {
                final data = json.decode(message);
                _handleMessage(data);
              }
            } catch (e) {
              print('Error parsing WebSocket message: $e');
            }
          },
          onError: (error) {
            print('WebSocket stream error: $error');
            _isConnected = false;
            _channel = null;
          },
          onDone: () {
            print('WebSocket disconnected');
            _isConnected = false;
            _channel = null;
          },
          cancelOnError: true,
        );
        
        // Store subscription to prevent it from being garbage collected
        // Only set connected and channel after listener is successfully set up
        _channel = channel;
        _isConnected = true;
      } catch (e, stackTrace) {
        // If listener setup fails (connection error), clean up
        print('Failed to set up WebSocket listener: $e');
        print('Stack trace: $stackTrace');
        try {
          channel.sink.close();
        } catch (_) {
          // Ignore close errors
        }
        _isConnected = false;
        _channel = null;
      }
    } catch (e) {
      // Catch any other connection errors
      print('Failed to connect WebSocket: $e');
      _isConnected = false;
      _channel = null;
      // Don't rethrow - this is non-critical
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    _isConnected = false;
    _channel = null;
  }
  
  void send(Map<String, dynamic> data) {
    if (!_isConnected || _channel == null) {
      print('WebSocket not connected - message not sent');
      return;
    }
    
    try {
      _channel!.sink.add(json.encode(data));
    } catch (e) {
      print('Error sending WebSocket message: $e');
      _isConnected = false;
      _channel = null;
    }
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
    }).where((message) => message.isNotEmpty);
  }
}

