#!/bin/bash
# Script to run Flutter app on connected Android phone

# Get computer IP address
IP=$(hostname -I | awk '{print $1}')

echo "🚀 Running Flutter app on your phone..."
echo "📱 Device: M2101K6I (d3bffd50)"
echo "🖥️  Backend IP: $IP:8002"
echo ""

cd frontend

flutter run -d d3bffd50 \
  --dart-define=API_BASE=http://$IP:8002/api/v1 \
  --dart-define=MEDIA_BASE=http://$IP:8002 \
  --dart-define=JITSI_SERVER=http://$IP:8000
