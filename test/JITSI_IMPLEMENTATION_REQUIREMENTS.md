# Jitsi Meet Implementation Requirements Guide

This document outlines all the information, configurations, and steps needed to properly implement the Jitsi Meet integration in your Flutter application.

## 1. Jitsi Meet Server Setup Information

### Required Information:
- **Server URL**: Your self-hosted Jitsi Meet server URL (e.g., `https://meet.yourdomain.com`)
- **Server Installation Method**: 
  - [ ] Docker deployment
  - [ ] Manual installation (Ubuntu/Debian)
  - [ ] Cloud deployment (AWS, GCP, Azure)
  - [ ] Other (specify)
- **Server Domain**: Full domain name for your Jitsi instance
- **SSL Certificate**: Confirm SSL/TLS is properly configured (HTTPS required)

### Server Configuration Details Needed:
1. **Jitsi Meet Web Configuration** (`/etc/jitsi/meet/yourdomain-config.js`)
   - Token-based authentication enabled: YES/NO
   - JWT authentication settings
   - Domain configuration
   - App ID (Application Identifier)
   - App Secret (Secret Key for JWT signing)

2. **Prosody Configuration** (`/etc/prosody/conf.avail/yourdomain.cfg.lua`)
   - Virtual host settings
   - Authentication method (token)
   - JWT authentication module enabled

3. **Jicofo Configuration** (`/etc/jitsi/jicofo/sip-communicator.properties`)
   - XMPP domain
   - Component secret (if applicable)

## 2. JWT Token Configuration

### Critical Information Needed:

1. **Application Identifier (App ID)**
   - What is your Jitsi App ID?
   - Where is it configured? (Usually in Jitsi config files)
   - Example format: `my-app-id` or `your-app-name`

2. **Application Secret Key**
   - What is your Jitsi App Secret?
   - How long is it? (Recommended: at least 32 characters)
   - Where is it stored? (Must match server configuration)

3. **JWT Token Structure Confirmation**
   - Verify the JWT payload structure matches:
     ```json
     {
       "iss": "your-app-id",
       "aud": "your-app-id",
       "sub": "yourdomain.com",
       "room": "room-name",
       "exp": expiration_timestamp,
       "moderator": true/false,
       "audio": true/false,
       "video": true/false,
       "name": "User Name",
       "email": "user@example.com"
     }
     ```
   - Confirm the algorithm: `HS256` (required for Jitsi)

4. **Token Expiration**
   - Default expiration time (in seconds)
   - Recommended: 2 hours (7200 seconds) for meetings
   - Can this be configurable per meeting type?

## 3. Environment Variables Configuration

### Backend (.env file) - Provide values for:
```bash
# Jitsi Meet Configuration
JITSI_APP_ID=?
JITSI_APP_SECRET=?
JITSI_SERVER_URL=?
JITSI_JWT_EXPIRATION=7200
```

### Frontend Configuration
- Update `frontend/lib/services/jitsi_config.dart`:
  ```dart
  static const String serverUrl = '?'; // Your Jitsi server URL
  ```

## 4. Server Setup Steps (What You Need to Research)

### Research Topics:
1. **How to install Jitsi Meet on your server**
   - Operating system compatibility
   - Installation method (Quick Install vs Manual)
   - System requirements (CPU, RAM, Storage)
   - Network requirements (ports, firewall)

2. **How to configure JWT authentication**
   - Enabling token-based authentication
   - Generating App ID and Secret
   - Configuring Prosody for JWT
   - Testing JWT token generation and validation

3. **Domain and SSL Setup**
   - DNS configuration for Jitsi domain
   - SSL certificate installation (Let's Encrypt recommended)
   - Nginx/Apache reverse proxy configuration (if applicable)

4. **Firewall and Port Configuration**
   - Required ports to open:
     - 443 (HTTPS)
     - 4443 (TURN/TCP)
     - 10000/UDP (RTP media)
     - 3478/UDP (STUN)
     - 5349/TCP (TURN/TLS)
   - Check if these ports are accessible

## 5. Platform-Specific Requirements

### Android Configuration
- **Minimum SDK Version**: Confirmed at 24 (already configured)
- **Permissions**: Already configured in AndroidManifest.xml
- **Additional Requirements**:
  - [ ] Test camera/microphone permissions at runtime
  - [ ] Verify ProGuard rules (if using code obfuscation)

### iOS Configuration (Need Information)
- **Minimum iOS Version**: What iOS version does Jitsi Meet SDK require?
- **Info.plist Permissions**: 
  - Camera usage description
  - Microphone usage description
- **Podfile Configuration**: 
  - iOS platform version requirement
  - Pod installation steps
- **Xcode Settings**: Any specific build settings needed?

## 6. Backend API Endpoints Verification

### Current Implementation:
- Endpoint: `POST /api/v1/live/streams/{stream_id}/join`
- Request Body:
  ```json
  {
    "identity": "user-id",
    "name": "User Name",
    "email": "user@example.com",
    "is_host": true/false
  }
  ```
- Response Format:
  ```json
  {
    "token": "jwt-token-string",
    "url": "https://meet.yourdomain.com",
    "room_name": "sanitized-room-name"
  }
  ```

### Questions to Research:
1. Do you need additional endpoints for:
   - Meeting creation (separate from stream creation)?
   - Meeting list/management?
   - Participant management?
   - Meeting termination?

2. Room name format requirements:
   - Maximum length?
   - Allowed characters?
   - Case sensitivity?
   - Special room names (reserved words)?

## 7. User Authentication Integration

### Current Implementation:
- Guest users with auto-generated IDs
- Host/Moderator role assignment

### Questions to Research:
1. **User Identity Management**:
   - Should we use authenticated user IDs from your auth system?
   - How to map your user system to Jitsi participant identities?
   - User display names - from where? (profile, auth token, etc.)

2. **Permissions/Roles**:
   - Who can create meetings?
   - Who can join meetings?
   - Moderator permissions - based on what criteria?
   - Should there be meeting passwords?

## 8. Meeting Features Configuration

### Features to Research and Configure:

1. **Audio/Video Defaults**:
   - Default audio muted for participants?
   - Default video off for participants?
   - Can hosts force mute all?

2. **Screen Sharing**:
   - Is screen sharing enabled?
   - Permissions required?
   - Platform limitations?

3. **Recording**:
   - Is recording enabled on server?
   - Who can start recording? (Moderators only?)
   - Storage location and access?

4. **Chat/Text Messages**:
   - Is chat enabled?
   - File sharing?
   - Emoji support?

5. **Waiting Room**:
   - Should we implement a waiting room?
   - Moderator approval required?
   - Automatic admission after delay?

6. **Meeting Duration Limits**:
   - Maximum meeting duration?
   - Maximum participants per meeting?
   - Automatic termination after host leaves?

## 9. Error Handling and Edge Cases

### Scenarios to Research:

1. **Connection Failures**:
   - What happens if Jitsi server is down?
   - Network timeout handling
   - Reconnection logic needed?

2. **Token Expiration**:
   - What happens when JWT expires during meeting?
   - Should we refresh tokens?
   - How long before expiration to refresh?

3. **Invalid Room Names**:
   - What happens if room doesn't exist?
   - Can we create rooms on-demand?
   - Room name conflicts?

4. **Participant Limits**:
   - Maximum participants reached
   - Error messages to display
   - Waitlist functionality?

## 10. Testing Requirements

### Test Scenarios to Prepare:

1. **Basic Functionality**:
   - [ ] Create instant meeting
   - [ ] Create scheduled meeting
   - [ ] Join meeting with ID
   - [ ] Join meeting with link
   - [ ] Multiple participants join
   - [ ] Leave meeting

2. **Audio/Video**:
   - [ ] Toggle microphone
   - [ ] Toggle camera
   - [ ] Switch camera (front/back)
   - [ ] Mute/unmute other participants (moderator)

3. **Permissions**:
   - [ ] Host/moderator permissions
   - [ ] Guest participant permissions
   - [ ] Camera/mic permission prompts
   - [ ] Permission denied handling

4. **Platform Testing**:
   - [ ] Android device testing
   - [ ] iOS device testing
   - [ ] Different screen sizes
   - [ ] Network conditions (WiFi, 4G, poor connection)

5. **Edge Cases**:
   - [ ] Expired token
   - [ ] Invalid room name
   - [ ] Server unreachable
   - [ ] App backgrounded/foregrounded during meeting

## 11. Security Considerations

### Research and Implement:

1. **JWT Token Security**:
   - Secret key storage (environment variables, not in code)
   - Token signing verification
   - Token expiration enforcement
   - Secure token transmission (HTTPS only)

2. **Room Security**:
   - Random room name generation
   - Room name validation
   - Protection against room name guessing
   - Optional room passwords

3. **User Privacy**:
   - User data in JWT tokens
   - PII handling (email, name)
   - Compliance requirements (GDPR, etc.)

## 12. Documentation and Resources Needed

### Please Research and Provide:

1. **Jitsi Meet Documentation Links**:
   - Self-hosting guide
   - JWT authentication setup guide
   - Mobile SDK documentation
   - API reference

2. **Server Logs and Debugging**:
   - Where are Jitsi logs stored?
   - How to enable debug logging?
   - Common error messages and solutions

3. **Community Resources**:
   - Jitsi community forum
   - GitHub issues
   - Troubleshooting guides

## 13. Deployment Checklist

### Pre-Deployment Requirements:

1. **Server Setup**:
   - [ ] Jitsi Meet installed and configured
   - [ ] Domain configured with DNS
   - [ ] SSL certificate installed
   - [ ] JWT authentication enabled and tested
   - [ ] Firewall ports opened
   - [ ] Server performance tested

2. **Configuration**:
   - [ ] App ID and Secret generated and secured
   - [ ] Environment variables set
   - [ ] Frontend config updated with server URL
   - [ ] Backend config updated with credentials

3. **Testing**:
   - [ ] End-to-end meeting flow tested
   - [ ] Multiple participants tested
   - [ ] Cross-platform tested
   - [ ] Error scenarios tested

4. **Monitoring**:
   - [ ] Server monitoring setup
   - [ ] Error logging configured
   - [ ] Analytics (if needed)

## 14. Specific Information to Provide

### Please Research and Provide:

1. **Your Jitsi Server Details**:
   ```
   Server URL: 
   Domain: 
   Installation Method: 
   App ID: 
   App Secret: (keep secure, provide separately)
   ```

2. **Your Server Configuration**:
   - Prosody config file content (sanitized, no secrets)
   - Jitsi Meet config file content
   - Any custom modifications made

3. **Your User System**:
   - How user authentication works
   - User ID format
   - User profile fields (name, email, avatar)
   - Role/permission system

4. **Your Requirements**:
   - Meeting features needed
   - Meeting duration limits
   - Participant limits
   - Recording requirements
   - Security requirements

5. **Testing Information**:
   - Test server URL (if different from production)
   - Test credentials
   - Test devices available

## 15. Next Steps After Research

Once you provide the information above, I will:

1. **Update Configuration Files**:
   - Backend environment configuration
   - Frontend Jitsi config
   - Service implementations with correct values

2. **Implement Missing Features**:
   - User authentication integration
   - Meeting management endpoints (if needed)
   - Error handling improvements
   - Platform-specific configurations

3. **Add Security Enhancements**:
   - Token validation
   - Room name sanitization
   - Permission checks
   - Input validation

4. **Create Testing Documentation**:
   - Test cases
   - Testing procedures
   - Troubleshooting guide

5. **Provide Deployment Instructions**:
   - Step-by-step deployment guide
   - Configuration checklist
   - Verification steps

## Priority Order for Research

1. **HIGH PRIORITY** (Required for basic functionality):
   - Jitsi server setup and URL
   - App ID and Secret configuration
   - JWT token structure confirmation
   - Basic meeting creation/joining

2. **MEDIUM PRIORITY** (Required for production):
   - User authentication integration
   - Security configuration
   - Error handling
   - Platform configurations (iOS)

3. **LOW PRIORITY** (Nice to have):
   - Advanced features (recording, waiting room)
   - Analytics and monitoring
   - Advanced permissions

## Questions to Answer

Please research and provide answers to these questions:

1. What is your Jitsi Meet server URL?
2. How did you install/configure Jitsi Meet?
3. What is your App ID and where is it configured?
4. What is your App Secret and how is it secured?
5. Is JWT authentication already working on your server?
6. What is your user authentication system?
7. What meeting features do you need?
8. What are your iOS deployment requirements?
9. Do you have test server/staging environment?
10. What security requirements do you have?

---

**Note**: Once you provide the above information, I can complete the implementation with proper configurations, error handling, and security measures tailored to your specific setup.

