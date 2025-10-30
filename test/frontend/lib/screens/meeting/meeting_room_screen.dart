import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class MeetingRoomScreen extends StatefulWidget {
  final String meetingId;
  final String livekitUrl;
  final String livekitToken;

  const MeetingRoomScreen({
    super.key,
    required this.meetingId,
    required this.livekitUrl,
    required this.livekitToken,
  });

  @override
  State<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends State<MeetingRoomScreen> {
  bool _connecting = true;
  String? _error;
  Room? _room;
  bool micEnabled = true;
  bool cameraEnabled = true;

  @override
  void initState() {
    super.initState();
    _joinRoom();
  }

  Future<void> _joinRoom() async {
    setState(() { _connecting = true; });
    try {
      final room = Room();
      await room.connect(widget.livekitUrl, widget.livekitToken);
      room.addListener(() => setState(() {})); // Update UI reactively (for tracks, events)
      setState(() {
        _room = room;
        _connecting = false;
        micEnabled = room.localParticipant?.isMicrophoneEnabled() ?? true;
        cameraEnabled = room.localParticipant?.isCameraEnabled() ?? true;
      });
    } catch (e) {
      setState(() {
        _connecting = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _room?.dispose();
    super.dispose();
  }

  void _leaveRoom() async {
    await _room?.disconnect();
    Navigator.pop(context);
  }

  void _toggleMic() async {
    if (_room == null) return;
    final mic = _room!.localParticipant?.isMicrophoneEnabled();
    final newMic = !(mic ?? false);
    await _room!.localParticipant?.setMicrophoneEnabled(newMic);
    setState(() { micEnabled = newMic; });
  }
  void _toggleCamera() async {
    if (_room == null) return;
    final cam = _room!.localParticipant?.isCameraEnabled();
    final newCam = !(cam ?? false);
    await _room!.localParticipant?.setCameraEnabled(newCam);
    setState(() { cameraEnabled = newCam; });
  }

  List<dynamic> _allParticipants() {
    if (_room == null) return [];
    final local = _room!.localParticipant;
    final remotes = _room!.remoteParticipants.values.toList();
    return [if (local != null) local, ...remotes];
  }

  Widget _videoFor(dynamic participant) {
    if (participant is LocalParticipant || participant is RemoteParticipant) {
      final videoTracks = participant.videoTracks.values.where((t) => t.track != null).toList();
      if (videoTracks.isNotEmpty && videoTracks.first.track != null) {
        return VideoTrackRenderer(videoTracks.first.track as VideoTrack);
      }
    }
    return Icon(Icons.videocam_off, size: 54, color: Colors.redAccent);
  }

  @override
  Widget build(BuildContext context) {
    if (_connecting) {
      return Scaffold(
        appBar: AppBar(title: const Text('Joining Meeting...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meeting Error')),
        body: Center(child: Text('Error: $_error')),
      );
    }
    final participants = _allParticipants();
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting: ${widget.meetingId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: Colors.red),
            onPressed: _leaveRoom,
            tooltip: 'Leave Meeting',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: participants.length,
              itemBuilder: (context, idx) {
                final participant = participants[idx];
                return Card(
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: _videoFor(participant),
                      ),
                      Positioned(
                        left: 8, top: 8,
                        child: Row(
                          children: [
                            Text(
                              participant.identity,
                              style: TextStyle(
                                fontWeight: participant is LocalParticipant ? FontWeight.bold : FontWeight.normal)),
                            const SizedBox(width: 6),
                            Icon(
                              (participant is LocalParticipant ? participant.isMicrophoneEnabled() : participant.isMicrophoneEnabled()) ? Icons.mic : Icons.mic_off,
                              size: 18,
                              color: (participant is LocalParticipant ? participant.isMicrophoneEnabled() : participant.isMicrophoneEnabled()) ? Colors.green : Colors.red),
                            const SizedBox(width: 2),
                            Icon(
                              (participant is LocalParticipant ? participant.isCameraEnabled() : participant.isCameraEnabled()) ? Icons.videocam : Icons.videocam_off,
                              size: 18,
                              color: (participant is LocalParticipant ? participant.isCameraEnabled() : participant.isCameraEnabled()) ? Colors.green : Colors.red)
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleMic,
                  icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                  label: Text(micEnabled ? 'Mute' : 'Unmute'),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleCamera,
                  icon: Icon(cameraEnabled ? Icons.videocam : Icons.videocam_off),
                  label: Text(cameraEnabled ? 'Camera Off' : 'Camera On'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
