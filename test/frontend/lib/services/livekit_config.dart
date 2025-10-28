class LiveKitConfig {
  static const String url = 'wss://christ-new-tabernacle-05wa8jtt.livekit.cloud';
  static const String apiKey = 'API2MUzze3cJxqE';
  static const String apiSecret = 'Zxiz8cGYkPE6kFhcSGUxdVgQkefchKkd6Wx3KfViiCAA';
  
  // Generate a JWT token for room access
  static String generateToken(String userId, String roomName) {
    // This is a simplified version - in production, generate JWT server-side
    // For now, return a placeholder that LiveKit server will handle
    return '';
  }
}
