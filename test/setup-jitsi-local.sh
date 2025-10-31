#!/bin/bash

# Jitsi Meet Local Setup Script
# This script sets up Jitsi Meet locally using Docker

set -e

echo "=========================================="
echo "Jitsi Meet Local Setup Script"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Create directory
JITSI_DIR="jitsi-meet-local"
if [ -d "$JITSI_DIR" ]; then
    echo "⚠️  Directory $JITSI_DIR already exists"
    read -p "Do you want to remove it and start fresh? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$JITSI_DIR"
        echo "✅ Removed existing directory"
    else
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

mkdir -p "$JITSI_DIR"
cd "$JITSI_DIR"

echo "📁 Created directory: $JITSI_DIR"
echo ""

# Generate random secrets
echo "🔐 Generating random secrets..."
JICOFO_COMPONENT_SECRET=$(openssl rand -hex 16)
JICOFO_AUTH_PASSWORD=$(openssl rand -hex 16)
JVB_AUTH_PASSWORD=$(openssl rand -hex 16)
JWT_APP_SECRET=$(openssl rand -hex 32)

echo "✅ Secrets generated"
echo ""

# Create .env file
echo "📝 Creating .env configuration file..."
cat > .env << EOF
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
JWT_APP_SECRET=$JWT_APP_SECRET
JWT_ACCEPTED_ISSUERS=my-app-id
JWT_ACCEPTED_AUDIENCES=my-app-id
JWT_TOKEN_AUTH_MODULE=token_verification
JWT_ALLOW_EMPTY=0

# Secrets
CONFIG=./jitsi-config
JICOFO_COMPONENT_SECRET=$JICOFO_COMPONENT_SECRET
JICOFO_AUTH_USER=focus
JICOFO_AUTH_PASSWORD=$JICOFO_AUTH_PASSWORD
JVB_AUTH_USER=jvb
JVB_AUTH_PASSWORD=$JVB_AUTH_PASSWORD

# SSL (disabled for local)
ENABLE_LETSENCRYPT=0
DISABLE_HTTPS=1
ENABLE_HTTP_REDIRECT=0

# JVB Configuration
JVB_PORT=10000
DOCKER_HOST_ADDRESS=127.0.0.1
JVB_ENABLE_APIS=rest,colibri

# Additional Settings
ENABLE_PREJOIN_PAGE=1
ENABLE_WELCOME_PAGE=1
ENABLE_CLOSE_PAGE=1
EOF

echo "✅ .env file created"
echo ""

# Download docker-compose.yml
echo "📥 Downloading docker-compose.yml..."
if command -v curl &> /dev/null; then
    curl -L -o docker-compose.yml https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/master/docker-compose.yml
elif command -v wget &> /dev/null; then
    wget -O docker-compose.yml https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/master/docker-compose.yml
else
    echo "⚠️  curl or wget not found. Please download docker-compose.yml manually from:"
    echo "https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/master/docker-compose.yml"
    exit 1
fi

echo "✅ docker-compose.yml downloaded"
echo ""

# Create config directories
echo "📁 Creating configuration directories..."
mkdir -p jitsi-config/{web,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,transcripts}
echo "✅ Directories created"
echo ""

# Create Prosody config for JWT
echo "📝 Creating Prosody JWT configuration..."
mkdir -p jitsi-config/prosody/config/conf.d
cat > jitsi-config/prosody/config/conf.d/jwt.cfg.lua << 'EOF'
-- JWT Authentication Configuration
plugin_paths = { "/prosody-plugins", "/prosody-plugins-custom" }

VirtualHost "meet.jitsi"
    authentication = "token"
    
    app_id = os.getenv("JWT_APP_ID") or "my-app-id"
    app_secret = os.getenv("JWT_APP_SECRET") or ""
    allow_empty_token = (os.getenv("JWT_ALLOW_EMPTY") == "1")
    
    modules_enabled = {
        "token_verification";
    }
    
    -- Token verification settings
    asap_key_server = os.getenv("JWT_ASAP_KEYSERVER") or ""
    accepted_issuers = { os.getenv("JWT_ACCEPTED_ISSUERS") or app_id }
    accepted_audiences = { os.getenv("JWT_ACCEPTED_AUDIENCES") or app_id }
EOF

echo "✅ Prosody JWT config created"
echo ""

# Start Docker containers
echo "🐳 Starting Docker containers..."
echo "This may take a few minutes on first run..."
docker-compose up -d

echo ""
echo "⏳ Waiting for containers to start..."
sleep 10

# Check container status
echo ""
echo "📊 Container Status:"
docker-compose ps

echo ""
echo "=========================================="
echo "✅ Jitsi Meet Setup Complete!"
echo "=========================================="
echo ""
echo "📍 Access Jitsi Meet at: http://localhost:8000"
echo ""
echo "🔑 Your Configuration:"
echo "   Server URL: http://localhost:8000"
echo "   App ID: my-app-id"
echo "   App Secret: $JWT_APP_SECRET"
echo ""
echo "📱 For Android Emulator, use: http://10.0.2.2:8000"
echo ""
echo "🧪 To test JWT authentication, run:"
echo "   cd $JITSI_DIR"
echo "   python3 test_jwt.py"
echo ""
echo "📋 Useful Commands:"
echo "   docker-compose logs -f    # View logs"
echo "   docker-compose restart    # Restart services"
echo "   docker-compose down       # Stop services"
echo ""
echo "⚠️  Important: Save your App Secret securely!"
echo "   App Secret: $JWT_APP_SECRET"
echo ""

