import 'package:http/http.dart' as http;
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'dart:convert';
import 'jitsi_config.dart';

class JitsiJoinResponse {
  final String token;
  final String url;
  final String roomName;
  JitsiJoinResponse({
    required this.token,
    required this.url,
    required this.roomName,
  });
}

/// Jitsi Meet Service for video conferencing functionality
/// Handles meeting room connection via Jitsi Meet SDK
class JitsiService {
  static final JitsiService _instance = JitsiService._internal();
  factory JitsiService() => _instance;
  JitsiService._internal();

  // Backend API base URL; emulator-safe default, override with --dart-define
  static String apiBase = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8002/api/v1',
  );

  /// Fetch JWT token for joining a meeting from backend
  Future<JitsiJoinResponse> fetchTokenForMeeting({
    required int streamOrMeetingId,
    required String userIdentity,
    required String userName,
    String? userEmail,
    bool isHost = false,
    String? apiBaseParam,
  }) async {
    // Use apiBase param if provided, else static default
    String apiUrl = apiBaseParam ?? apiBase;
    // Pass host flag as query param for FastAPI (not in JSON body)
    final url = Uri.parse('$apiUrl/live/streams/$streamOrMeetingId/join${isHost ? '?is_host=true' : ''}');
    try {
      // Build JSON body without null email field
      final Map<String, dynamic> body = {
        'identity': userIdentity,
        'name': userName,
      };
      if (userEmail != null && userEmail.isNotEmpty) {
        body['email'] = userEmail;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JitsiJoinResponse(
          token: data['token'],
          url: data['url'] ?? JitsiConfig.serverUrl,
          roomName: data['room_name'],
        );
      } else {
        throw Exception(
            'Failed to fetch Jitsi token: HTTP ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch JWT token by room name (for link-based joins)
  Future<JitsiJoinResponse> fetchTokenForMeetingByRoom({
    required String roomName,
    required String userIdentity,
    required String userName,
    String? userEmail,
    bool isHost = false,
    String? apiBaseParam,
  }) async {
    final apiUrl = apiBaseParam ?? apiBase;
    final url = Uri.parse('$apiUrl/live/streams/by-room/$roomName/join${isHost ? '?is_host=true' : ''}');
    try {
      final body = <String, dynamic>{
        'identity': userIdentity,
        'name': userName,
      };
      if (userEmail != null && userEmail.isNotEmpty) body['email'] = userEmail;
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return JitsiJoinResponse(
          token: data['token'],
          url: data['url'] ?? JitsiConfig.serverUrl,
          roomName: data['room_name'],
        );
      }
      throw Exception('Failed to fetch Jitsi token by room: HTTP ${response.statusCode} ${response.body}');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Join a Jitsi Meet conference
  Future<void> joinConference({
    required String roomName,
    required String jwtToken,
    required String displayName,
    String? email,
    bool audioMuted = false,
    bool videoMuted = false,
    bool isModerator = false,
  }) async {
    final jitsiMeet = JitsiMeet();
    
    final options = JitsiMeetConferenceOptions(
      serverURL: JitsiConfig.serverUrl,
      room: roomName,
      token: jwtToken,
      userInfo: JitsiMeetUserInfo(
        displayName: displayName,
        email: email,
      ),
      configOverrides: {
        'startWithAudioMuted': audioMuted,
        'startWithVideoMuted': videoMuted,
      },
      featureFlags: {
        'call-integration.enabled': false,
        'live-streaming.enabled': false,
        'recording.enabled': false,
      },
    );

    await jitsiMeet.join(options);
  }

  /// Close/leave the current conference
  Future<void> leaveConference() async {
    final jitsiMeet = JitsiMeet();
    await jitsiMeet.hangUp();
  }
}

