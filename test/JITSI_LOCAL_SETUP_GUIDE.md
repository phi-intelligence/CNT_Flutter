# Jitsi Meet Local Server Setup Guide

This guide will help you set up Jitsi Meet server locally for development and testing.

## Prerequisites

### Required Software:
- [ ] Docker and Docker Compose installed
  - Docker: https://docs.docker.com/get-docker/
  - Docker Compose: Usually comes with Docker Desktop
- [ ] At least 4GB RAM available
- [ ] Ports available: 80, 443, 4443, 10000/udp

### System Requirements:
- Linux, macOS, or Windows with WSL2
- Minimum 4GB RAM (8GB recommended)
- Internet connection

## Method 1: Docker Setup (Recommended for Local Development)

### Step 1: Create Setup Directory

```bash
mkdir jitsi-meet
cd jitsi-meet
```

### Step 2: Create Docker Compose File

Create a file named `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # Frontend - Jitsi Meet web interface
  web:
    image: jitsi/web:latest
    restart: unless-stopped
    ports:
      - '${HTTP_PORT:-80}:80'
      - '${HTTPS_PORT:-443}:443'
    volumes:
      - ${CONFIG}/web:/config:Z
      - ${CONFIG}/web/letsencrypt:/etc/letsencrypt:Z
    environment:
      - ENABLE_AUTH
      - ENABLE_GUESTS
      - ENABLE_LETSENCRYPT
      - ENABLE_HTTP_REDIRECT
      - DISABLE_HTTPS
      - JICOFO_AUTH_USER
      - LETSENCRYPT_DOMAIN
      - LETSENCRYPT_EMAIL
      - PUBLIC_URL
      - XMPP_DOMAIN
      - XMPP_AUTH_DOMAIN
      - XMPP_GUEST_DOMAIN
      - XMPP_MUC_DOMAIN
      - XMPP_INTERNAL_MUC_DOMAIN
      - XMPP_RECORDER_DOMAIN
      - XMPP_MODULES
      - XMPP_MUC_MODULES
      - XMPP_INTERNAL_MUC_MODULES
      - ENABLE_P2P
      - ENABLE_IPV6
      - ENABLE_PREJOIN_PAGE
      - ENABLE_WELCOME_PAGE
      - ENABLE_CLOSE_PAGE
      - ENABLE_RECORDING
      - JIBRI_BREWERY_MUC
      - JIBRI_PENDING_TIMEOUT
      - JIBRI_XMPP_USER
      - JIBRI_XMPP_PASSWORD
      - JIBRI_RECORDER_USER
      - JIBRI_RECORDER_PASSWORD
      - ENABLE_REMB
      - ENABLE_TCC
      - ENABLE_SIMULCAST
      - RESOLUTION
      - FRAME_RATE
      - CHANNEL_LASTN
      - START_BITRATE
      - STUN_SERVERS
      - XMPP_DOMAIN
      - XMPP_AUTH_DOMAIN
      - XMPP_MUC_DOMAIN
      - XMPP_INTERNAL_MUC_DOMAIN
      - XMPP_GUEST_DOMAIN
      - XMPP_RECORDER_DOMAIN
      - JVB_AUTH_PASSWORD
      - JVB_AUTH_USER
      - JVB_BREWERY_MUC
      - JVB_PORT
      - JVB_STUN_SERVERS
      - JVB_ENABLE_APIS
      - JVB_WS_DOMAIN
      - JVB_WS_SERVER_ID
    networks:
      - meet.jitsi

  # Prosody - XMPP server
  prosody:
    image: jitsi/prosody:latest
    restart: unless-stopped
    expose:
      - '5222'
      - '5347'
      - '5280'
      - '5281'
    volumes:
      - ${CONFIG}/prosody/config:/config:Z
    environment:
      - AUTH_TYPE
      - ENABLE_AUTH
      - ENABLE_GUESTS
      - ENABLE_ANONYMOUS
      - GLOBAL_MODULES
      - ADVERTISED_MODULES
      - XMPP_DOMAIN
      - XMPP_AUTH_DOMAIN
      - XMPP_GUEST_DOMAIN
      - XMPP_MUC_DOMAIN
      - XMPP_INTERNAL_MUC_DOMAIN
      - XMPP_RECORDER_DOMAIN
      - XMPP_MODULES
      - XMPP_MUC_MODULES
      - XMPP_INTERNAL_MUC_MODULES
      - XMPP_RECORDER_MODULES
      - JICOFO_COMPONENT_SECRET
      - JICOFO_AUTH_USER
      - JICOFO_AUTH_PASSWORD
      - JVB_AUTH_USER
      - JVB_AUTH_PASSWORD
      - JVB_AUTH_PASSWORD
      - JIGASI_XMPP_USER
      - JIGASI_XMPP_PASSWORD
      - JIBRI_XMPP_USER
      - JIBRI_XMPP_PASSWORD
      - JIBRI_RECORDER_USER
      - JIBRI_RECORDER_PASSWORD
      - JWT_APP_ID
      - JWT_APP_SECRET
      - JWT_ACCEPTED_ISSUERS
      - JWT_ACCEPTED_AUDIENCES
      - JWT_ASAP_KEYSERVER
      - JWT_ALLOW_EMPTY
      - JWT_AUTH_TYPE
      - JWT_TOKEN_AUTH_MODULE
      - LOG_LEVEL
    networks:
      - meet.jitsi

  # Jicofo - Conference focus
  jicofo:
    image: jitsi/jicofo:latest
    restart: unless-stopped
    volumes:
      - ${CONFIG}/jicofo:/config:Z
    environment:
      - ENABLE_AUTH
      - XMPP_DOMAIN
      - XMPP_AUTH_DOMAIN
      - XMPP_INTERNAL_MUC_DOMAIN
      - XMPP_SERVER
      - JICOFO_COMPONENT_SECRET
      - JICOFO_AUTH_USER
      - JICOFO_AUTH_PASSWORD
      - JICOFO_ENABLE_BRIDGE_HEALTH_CHECKS
      - JVB_BREWERY_MUC
      - JVB_PORT
      - JIGASI_BREWERY_MUC
      - JIGASI_PORT
      - TZ
      - ENABLE_SCTP
      - JVB_TCP_HARVESTER_DISABLED
      - JVB_TCP_PORT
      - JVB_TCP_MAPPED_PORT
      - JVB_STUN_SERVERS
    depends_on:
      - prosody
    networks:
      - meet.jitsi

  # JVB - Jitsi Videobridge
  jvb:
    image: jitsi/jvb:latest
    restart: unless-stopped
    ports:
      - '${JVB_PORT:-10000}/udp:10000/udp'
      - '${JVB_TCP_PORT:-4443}:4443/tcp'
    volumes:
      - ${CONFIG}/jvb:/config:Z
    environment:
      - DOCKER_HOST_ADDRESS
      - XMPP_AUTH_DOMAIN
      - XMPP_INTERNAL_MUC_DOMAIN
      - XMPP_SERVER
      - JVB_AUTH_USER
      - JVB_AUTH_PASSWORD
      - JVB_BREWERY_MUC
      - JVB_PORT
      - JVB_STUN_SERVERS
      - JVB_ENABLE_APIS
      - JVB_WS_DOMAIN
      - JVB_WS_SERVER_ID
      - TZ
      - PUBLIC_URL
      - ENABLE_SCTP
      - JVB_TCP_HARVESTER_DISABLED
      - JVB_TCP_PORT
      - JVB_TCP_MAPPED_PORT
    depends_on:
      - prosody
    networks:
      - meet.jitsi

networks:
  meet.jitsi:
    driver: bridge
```

### Step 3: Create Environment File

Create a file named `.env`:

```bash
# Version
COMPOSE_PROJECT_NAME=jitsi

# Jitsi Configuration
HTTP_PORT=8000
HTTPS_PORT=8443
TZ=UTC
PUBLIC_URL=http://localhost:8000

# Domain Configuration (for local use)
XMPP_DOMAIN=meet.jitsi
XMPP_AUTH_DOMAIN=auth.meet.jitsi
XMPP_MUC_DOMAIN=muc.meet.jitsi
XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi
XMPP_GUEST_DOMAIN=guest.meet.jitsi
XMPP_RECORDER_DOMAIN=recorder.meet.jitsi

# Authentication
ENABLE_AUTH=1
ENABLE_GUESTS=1
AUTH_TYPE=token
ENABLE_ANONYMOUS=0

# JWT Configuration
JWT_APP_ID=my-app-id
JWT_APP_SECRET=my-secret-key-change-this-in-production
JWT_ACCEPTED_ISSUERS=my-app-id
JWT_ACCEPTED_AUDIENCES=my-app-id
JWT_TOKEN_AUTH_MODULE=token_verification

# Secrets (auto-generated, change if needed)
CONFIG=./jitsi-config
JICOFO_COMPONENT_SECRET=$(openssl rand -hex 16)
JICOFO_AUTH_USER=focus
JICOFO_AUTH_PASSWORD=$(openssl rand -hex 16)
JVB_AUTH_USER=jvb
JVB_AUTH_PASSWORD=$(openssl rand -hex 16)

# SSL (disabled for local)
ENABLE_LETSENCRYPT=0
DISABLE_HTTPS=1
ENABLE_HTTP_REDIRECT=0

# JVB Configuration
JVB_PORT=10000
DOCKER_HOST_ADDRESS=127.0.0.1
JVB_ENABLE_APIS=rest,colibri
```

### Step 4: Generate Secrets

Run this command to generate random secrets:

```bash
# Create config directory
mkdir -p jitsi-config/{web,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,transcripts}

# Generate secrets (already in .env, but you can regenerate)
JICOFO_COMPONENT_SECRET=$(openssl rand -hex 16)
JICOFO_AUTH_PASSWORD=$(openssl rand -hex 16)
JVB_AUTH_PASSWORD=$(openssl rand -hex 16)

echo "JICOFO_COMPONENT_SECRET=$JICOFO_COMPONENT_SECRET"
echo "JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD"
echo "JVB_AUTH_PASSWORD=$JVB_AUTH_PASSWORD"
```

### Step 5: Start Jitsi Meet

```bash
docker-compose up -d
```

Wait for all containers to start (check with `docker-compose ps`).

### Step 6: Access Jitsi Meet

Open your browser and go to:
- `http://localhost:8000`

You should see the Jitsi Meet interface!

## Method 2: Quick Setup Script (Alternative)

Create a setup script `setup-jitsi.sh`:

```bash
#!/bin/bash

echo "Setting up Jitsi Meet locally..."

# Create directory structure
mkdir -p jitsi-meet/jitsi-config/{web,prosody/config,jicofo,jvb}
cd jitsi-meet

# Download docker-compose file
curl -o docker-compose.yml https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/master/docker-compose.yml

# Generate .env file
cat > .env << EOF
COMPOSE_PROJECT_NAME=jitsi
HTTP_PORT=8000
HTTPS_PORT=8443
TZ=UTC
PUBLIC_URL=http://localhost:8000
XMPP_DOMAIN=meet.jitsi
XMPP_AUTH_DOMAIN=auth.meet.jitsi
XMPP_MUC_DOMAIN=muc.meet.jitsi
XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi
XMPP_GUEST_DOMAIN=guest.meet.jitsi
XMPP_RECORDER_DOMAIN=recorder.meet.jitsi
ENABLE_AUTH=1
ENABLE_GUESTS=1
AUTH_TYPE=token
JWT_APP_ID=my-app-id
JWT_APP_SECRET=my-secret-key-change-this
JWT_ACCEPTED_ISSUERS=my-app-id
JWT_ACCEPTED_AUDIENCES=my-app-id
JWT_TOKEN_AUTH_MODULE=token_verification
ENABLE_LETSENCRYPT=0
DISABLE_HTTPS=1
CONFIG=./jitsi-config
JICOFO_COMPONENT_SECRET=$(openssl rand -hex 16)
JICOFO_AUTH_USER=focus
JICOFO_AUTH_PASSWORD=$(openssl rand -hex 16)
JVB_AUTH_USER=jvb
JVB_AUTH_PASSWORD=$(openssl rand -hex 16)
JVB_PORT=10000
DOCKER_HOST_ADDRESS=127.0.0.1
EOF

echo ".env file created with generated secrets"
echo "Now run: docker-compose up -d"
```

## Configure JWT Authentication

### Step 1: Update Prosody Configuration

After containers start, edit the Prosody config:

```bash
# Edit Prosody config
nano jitsi-config/prosody/config/conf.d/meet.jitsi.cfg.lua
```

Add or verify these settings:

```lua
VirtualHost "meet.jitsi"
    authentication = "token"
    app_id = "my-app-id"
    app_secret = "my-secret-key-change-this"
    allow_empty_token = false
    
    -- Token verification module
    modules_enabled = {
        "token_verification";
    }
```

### Step 2: Restart Prosody

```bash
docker-compose restart prosody
```

## Testing JWT Token Generation

### Python Script to Test JWT

Create `test_jwt.py`:

```python
import jwt
import time

# Your configuration
APP_ID = "my-app-id"
APP_SECRET = "my-secret-key-change-this"
SERVER_DOMAIN = "meet.jitsi"
ROOM_NAME = "test-room"

# Create JWT payload
payload = {
    "iss": APP_ID,
    "aud": APP_ID,
    "sub": SERVER_DOMAIN,
    "room": ROOM_NAME,
    "exp": int(time.time()) + 7200,  # 2 hours
    "moderator": True,
    "audio": True,
    "video": True,
    "name": "Test User",
}

# Generate token
token = jwt.encode(payload, APP_SECRET, algorithm="HS256")
print(f"JWT Token: {token}")
print(f"\nTest URL: http://localhost:8000/{ROOM_NAME}?jwt={token}")
```

Run it:
```bash
pip install PyJWT
python test_jwt.py
```

## Update Your Flutter App Configuration

Once the server is running, update these files:

### 1. Frontend Config (`frontend/lib/services/jitsi_config.dart`):
```dart
static const String serverUrl = 'http://localhost:8000';
```

### 2. Backend Config (`backend/.env`):
```bash
JITSI_APP_ID=my-app-id
JITSI_APP_SECRET=my-secret-key-change-this
JITSI_SERVER_URL=http://localhost:8000
JITSI_JWT_EXPIRATION=7200
```

### 3. For Android Emulator:
Since Android emulator can't access `localhost` directly, use:
- `http://10.0.2.2:8000` (Android emulator special IP)
- Update `jitsi_config.dart`:
```dart
static const String serverUrl = 'http://10.0.2.2:8000';
```

### 4. For iOS Simulator:
iOS simulator can use `localhost`:
```dart
static const String serverUrl = 'http://localhost:8000';
```

## Common Issues & Solutions

### Issue 1: Port Already in Use
```bash
# Change ports in .env
HTTP_PORT=8080
HTTPS_PORT=8444
```

### Issue 2: Docker Containers Won't Start
```bash
# Check logs
docker-compose logs

# Remove and recreate
docker-compose down -v
docker-compose up -d
```

### Issue 3: Can't Access from Mobile
- For Android emulator: Use `10.0.2.2` instead of `localhost`
- For physical device: Use your computer's local IP (e.g., `192.168.1.100:8000`)

### Issue 4: JWT Authentication Not Working
- Verify `AUTH_TYPE=token` in `.env`
- Check Prosody config has JWT settings
- Verify App ID and Secret match
- Restart all containers: `docker-compose restart`

## Verification Checklist

- [ ] Docker containers are running (`docker-compose ps`)
- [ ] Can access `http://localhost:8000` in browser
- [ ] Jitsi Meet interface loads
- [ ] Can create a test room without authentication
- [ ] JWT token can be generated
- [ ] Can join with JWT token: `http://localhost:8000/room?jwt=TOKEN`

## Next Steps After Setup

1. **Test Basic Functionality**:
   - Create a room manually
   - Join from browser
   - Test audio/video

2. **Test JWT Authentication**:
   - Generate test token
   - Join room with token
   - Verify moderator permissions

3. **Update Flutter App**:
   - Update server URL in config
   - Test meeting creation
   - Test meeting joining

4. **Provide Information for Code Update**:
   ```
   Server URL: http://localhost:8000 (or 10.0.2.2:8000 for Android emulator)
   App ID: my-app-id
   App Secret: my-secret-key-change-this
   ```

## Useful Commands

```bash
# Start Jitsi
docker-compose up -d

# Stop Jitsi
docker-compose down

# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart prosody

# Rebuild containers
docker-compose up -d --build

# Check container status
docker-compose ps
```

## Production Considerations

For production, you'll need:
- Real domain name
- SSL certificate (Let's Encrypt)
- Change `DISABLE_HTTPS=0` and `ENABLE_LETSENCRYPT=1`
- Use strong, random `JWT_APP_SECRET`
- Set `PUBLIC_URL` to your domain
- Proper firewall configuration

---

**Once you've completed the setup, provide me with:**
1. Server URL (localhost:8000 or your local IP)
2. App ID (from .env file)
3. App Secret (from .env file)

Then I'll update all the configuration files in your Flutter app!

