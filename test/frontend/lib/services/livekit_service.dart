import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveKitJoinResponse {
  final String token;
  final String url;
  final String roomName;
  LiveKitJoinResponse({required this.token, required this.url, required this.roomName});
}

/// LiveKit Service for live streaming functionality
/// Handles room connection, audio/video tracks, and streaming
class LiveKitService {
  static final LiveKitService _instance = LiveKitService._internal();
  factory LiveKitService() => _instance;
  LiveKitService._internal();

  // Backend API base URL; emulator-safe default, override with --dart-define
  static String apiBase = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  dynamic _currentRoom;
  dynamic _localParticipant;
  
  dynamic get currentRoom => _currentRoom;
  dynamic get localParticipant => _localParticipant;

  Future<LiveKitJoinResponse> fetchTokenForMeeting({
    required int streamOrMeetingId,
    required String userIdentity,
    bool isHost = false,
    String? apiBaseParam,
  }) async {
    // Use apiBase param if provided, else static default
    String apiUrl = apiBaseParam ?? apiBase;
    final url = Uri.parse('$apiUrl/streams/$streamOrMeetingId/join');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identity': userIdentity, 'is_host': isHost}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return LiveKitJoinResponse(
          token: data['token'],
          url: data['url'],
          roomName: data['room_name'],
        );
      } else {
        throw Exception('Failed to fetch LiveKit token: HTTP ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Disconnect from current room
  Future<void> disconnect() async {
    await _currentRoom?.disconnect();
    _currentRoom = null;
    _localParticipant = null;
  }

  /// Enable/disable camera
  Future<void> setCameraEnabled(bool enabled) async {
    try {
      // Placeholder - will be implemented with actual LiveKit setup
    } catch (e) {
      print('Error toggling camera: $e');
    }
  }

  /// Enable/disable microphone
  Future<void> setMicrophoneEnabled(bool enabled) async {
    try {
      // Placeholder - will be implemented with actual LiveKit setup
    } catch (e) {
      print('Error toggling microphone: $e');
    }
  }

  /// Flip camera (front/back)
  Future<void> flipCamera() async {
    try {
      // Toggle between front and back camera
      // This will be handled at the camera controller level
    } catch (e) {
      print('Error flipping camera: $e');
    }
  }

  /// Check if camera is enabled
  // SDK requires method calls: isCameraEnabled()
  bool get isCameraEnabled {
    return _localParticipant?.isCameraEnabled() ?? false;
  }

  /// Check if microphone is enabled
  // SDK requires method calls: isMicrophoneEnabled()
  bool get isMicrophoneEnabled {
    return _localParticipant?.isMicrophoneEnabled() ?? false;
  }

  /// Get remote participants
  List<dynamic> get remoteParticipants {
    return _currentRoom?.remoteParticipants.values.toList() ?? [];
  }

  /// Get total participant count
  int get participantCount {
    return (_currentRoom?.remoteParticipants.length ?? 0) + 1; // +1 for local
  }
}

