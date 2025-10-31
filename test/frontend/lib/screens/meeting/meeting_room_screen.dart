import 'package:flutter/material.dart';
import '../../services/jitsi_service.dart';

/// Meeting Room Screen - Entry point that launches Jitsi Meet
/// Note: Jitsi Meet SDK handles the full meeting UI internally
/// This screen is mainly for navigation purposes
class MeetingRoomScreen extends StatefulWidget {
  final String meetingId;
  final String roomName;
  final String jwtToken;
  final String userName;
  final bool isHost;

  const MeetingRoomScreen({
    super.key,
    required this.meetingId,
    required this.roomName,
    required this.jwtToken,
    required this.userName,
    this.isHost = false,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  bool _joining = true;

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  Future<void> _joinMeeting() async {
    try {
      await JitsiService().joinConference(
        roomName: widget.roomName,
        jwtToken: widget.jwtToken,
        displayName: widget.userName,
        audioMuted: false,
        videoMuted: false,
        isModerator: widget.isHost,
      );
      
      // When Jitsi meeting ends, user will be returned here
      // Navigate back to previous screen
      if (mounted) {
      setState(() {
          _joining = false;
      });
        Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/');
      }
    } catch (e) {
      if (mounted) {
      setState(() {
          _joining = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join meeting: $e')),
        );
    Navigator.pop(context);
  }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Joining Meeting...'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
            if (_joining)
              const CircularProgressIndicator()
            else
              Column(
                    children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                  const SizedBox(height: 16),
                  const Text('Meeting ended'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
                ),
              ],
            ),
      ),
    );
  }
}
