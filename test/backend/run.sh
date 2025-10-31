#!/usr/bin/env bash
# Start FastAPI on port 8002
set -euo pipefail
cd "$(dirname "$0")"
source venv/bin/activate
exec uvicorn app.main:app --reload --host 0.0.0.0 --port 8002
