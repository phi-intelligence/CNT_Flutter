import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'meeting_room_screen.dart';

class PrejoinScreen extends StatefulWidget {
  final String meetingId;
  final String livekitUrl;
  final String livekitToken;
  final String roomName;
  final bool isHost;
  const PrejoinScreen({
    super.key,
    required this.meetingId,
    required this.livekitUrl,
    required this.livekitToken,
    required this.roomName,
    this.isHost = false,
  });

  @override
  State<PrejoinScreen> createState() => _PrejoinScreenState();
}

class _PrejoinScreenState extends State<PrejoinScreen> {
  bool cameraEnabled = true;
  bool micEnabled = true;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  List<MediaDevice> _videoInputs = [];
  List<MediaDevice> _audioInputs = [];
  MediaDevice? _selectedCamera;
  MediaDevice? _selectedMic;
  bool _loadingDevices = true;

  @override
  void initState() {
    super.initState();
    _initDevices();
  }

  Future<void> _initDevices() async {
    setState(() { _loadingDevices = true; });
    final devices = await Hardware.instance.enumerateDevices();
    final videoInputs = devices.where((d) => d.kind == 'videoinput').toList();
    final audioInputs = devices.where((d) => d.kind == 'audioinput').toList();
    final selectedCamera = videoInputs.isNotEmpty ? videoInputs[0] : null;
    final selectedMic = audioInputs.isNotEmpty ? audioInputs[0] : null;
    setState(() {
      _videoInputs = videoInputs;
      _audioInputs = audioInputs;
      _selectedCamera = selectedCamera;
      _selectedMic = selectedMic;
      _loadingDevices = false;
    });
    await _createTracks();
  }

  Future<void> _createTracks() async {
    await _localVideoTrack?.dispose();
    await _localAudioTrack?.dispose();
    if (_selectedCamera != null) {
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        CameraCaptureOptions(deviceId: _selectedCamera!.deviceId),
      );
      // SDK: dispose and recreate the track if needed as toggle. No setMute or setEnabled in current SDK. Use local state to create/tear down as needed.
      // Optionally: just leave the track if toggling isn't exposed.
    }
    if (_selectedMic != null) {
      _localAudioTrack = await LocalAudioTrack.create(
        AudioCaptureOptions(deviceId: _selectedMic!.deviceId),
      );
      // SDK: same as above, dispose & reinit for toggle.
    }
    setState(() {});
  }

  void _onCameraChanged(MediaDevice cameraDevice) async {
    setState(() { _selectedCamera = cameraDevice; });
    await _createTracks();
  }

  void _onMicChanged(MediaDevice micDevice) async {
    setState(() { _selectedMic = micDevice; });
    await _createTracks();
  }

  @override
  void dispose() {
    _localVideoTrack?.dispose();
    _localAudioTrack?.dispose();
    super.dispose();
  }

  void _onJoin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MeetingRoomScreen(
          meetingId: widget.meetingId,
          livekitUrl: widget.livekitUrl,
          livekitToken: widget.livekitToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Check Your Setup')),
      body: _loadingDevices
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: cameraEnabled && _localVideoTrack != null
                          ? VideoTrackRenderer(_localVideoTrack!)
                          : const Icon(Icons.videocam_off, color: Colors.red, size: 120),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<MediaDevice>(
                          value: _selectedCamera,
                          items: _videoInputs.map((cam) => DropdownMenuItem(
                            value: cam,
                            child: Text(cam.label),
                          )).toList(),
                          onChanged: (val) { if (val != null) _onCameraChanged(val); },
                          isExpanded: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButton<MediaDevice>(
                          value: _selectedMic,
                          items: _audioInputs.map((mic) => DropdownMenuItem(
                            value: mic,
                            child: Text(mic.label),
                          )).toList(),
                          onChanged: (val) { if (val != null) _onMicChanged(val); },
                          isExpanded: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(cameraEnabled ? Icons.videocam : Icons.videocam_off),
                        iconSize: 36,
                        color: cameraEnabled ? Colors.blue : Colors.red,
                        tooltip: cameraEnabled ? 'Turn camera off' : 'Turn camera on',
                        onPressed: () {
                          setState(() { cameraEnabled = !cameraEnabled; });
                          // If SDK allows, re-create track on toggle - else, just update UI state.
                        },
                      ),
                      IconButton(
                        icon: Icon(micEnabled ? Icons.mic : Icons.mic_off),
                        iconSize: 36,
                        color: micEnabled ? Colors.blue : Colors.red,
                        tooltip: micEnabled ? 'Mute myself' : 'Unmute myself',
                        onPressed: () {
                          setState(() { micEnabled = !micEnabled; });
                          // If SDK allows, re-create track on toggle - else, just update UI state.
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.meeting_room),
                      label: const Text('Join Meeting'),
                      onPressed: _onJoin,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
