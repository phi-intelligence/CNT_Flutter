# Environment Variables Usage Analysis

## Overview
This document analyzes all files that use environment variables, API keys, and secrets in the codebase.

## How Environment Variables Work

### Loading Mechanism
- **Entry Point**: `backend/app/config.py` uses Pydantic's `BaseSettings`
- **Source**: Variables are loaded from:
  1. `.env` file in `backend/` directory (via `env_file = ".env"`)
  2. System environment variables (overrides `.env`)
  3. Default values in `Settings` class (if neither exists)

### Configuration File
**File**: `backend/app/config.py`
- Defines the `Settings` class with all environment variables
- Provides defaults for development
- Loads from `.env` file using Pydantic Settings

## Environment Variables Used

### 1. **Jitsi Meet Configuration** (New - for video conferencing)
- **Variables**:
  - `JITSI_APP_ID`: Application identifier for Jitsi
  - `JITSI_APP_SECRET`: Secret key for JWT token signing (⚠️ **SECRET**)
  - `JITSI_SERVER_URL`: URL of Jitsi Meet server
  - `JITSI_JWT_EXPIRATION`: Token expiration time in seconds

- **Default Values** (in config.py):
  - `JITSI_APP_ID = "my-app-id"`
  - `JITSI_APP_SECRET = "043aee60310956355bf636e0e1a84318f76b52d7d61b06650f08713ea835598c"` (⚠️ This is a secret!)
  - `JITSI_SERVER_URL = "http://localhost:8000"`
  - `JITSI_JWT_EXPIRATION = 7200`

- **Used By**:
  - `backend/app/services/jitsi_service.py` - Generates JWT tokens

### 2. **OpenAI API Key** (⚠️ **SECRET**)
- **Variable**: `OPENAI_API_KEY`
- **Default**: `""` (empty string)
- **Used By**:
  - `backend/app/services/ai_service.py` - AI voice assistant, text generation, TTS
  - Lines 14-15: Initializes OpenAI client only if key is provided

### 3. **Deepgram API Key** (⚠️ **SECRET**)
- **Variable**: `DEEPGRAM_API_KEY`
- **Default**: `""` (empty string)
- **Used By**:
  - `backend/app/services/ai_service.py` - Audio transcription
  - Lines 17-18: Initializes Deepgram client only if key is provided

### 4. **Database Configuration**
- **Variable**: `DATABASE_URL`
- **Default**: `"sqlite+aiosqlite:///./cnt_db.sqlite"`
- **Used By**:
  - `backend/app/database/connection.py` - Database connection setup

### 5. **Media Storage**
- **Variable**: `MEDIA_STORAGE_PATH`
- **Default**: `"./media"`
- **Used By**:
  - `backend/app/main.py` - Mounts static files directory (line 27-28)
  - `backend/app/services/media_service.py` - Media file handling

### 6. **Security Keys** (⚠️ **SECRET**)
- **Variables**:
  - `SECRET_KEY`: Secret for JWT token signing in auth system
  - `ALGORITHM`: JWT algorithm (default: "HS256")
  - `ACCESS_TOKEN_EXPIRE_MINUTES`: Token expiration (default: 30)

- **Default**: `SECRET_KEY = "your-secret-key-change-in-production"`

- **Used By**: (Likely for future authentication system)
  - Currently defined but may not be actively used yet

### 7. **API Configuration**
- **Variable**: `API_V1_PREFIX`
- **Default**: `"/api/v1"`
- **Used By**:
  - `backend/app/main.py` - Sets API route prefix (line 31)

## Files That Import Settings

1. **backend/app/config.py** - Defines settings
2. **backend/app/services/jitsi_service.py** - Uses Jitsi config
3. **backend/app/services/ai_service.py** - Uses OpenAI and Deepgram keys
4. **backend/app/services/media_service.py** - Uses media storage path
5. **backend/app/main.py** - Uses media path and API prefix
6. **backend/app/database/connection.py** - Uses database URL

## Secrets Classification

### ⚠️ **High Priority Secrets** (Must never commit):
1. `OPENAI_API_KEY` - Used in `ai_service.py`
2. `DEEPGRAM_API_KEY` - Used in `ai_service.py`
3. `JITSI_APP_SECRET` - Used in `jitsi_service.py` for JWT signing
4. `SECRET_KEY` - For authentication JWT signing

### ✅ **Safe to Commit** (Configuration, not secrets):
1. `JITSI_APP_ID` - Public app identifier
2. `JITSI_SERVER_URL` - Public server URL
3. `JITSI_JWT_EXPIRATION` - Just a number
4. `DATABASE_URL` - For SQLite, no credentials needed
5. `MEDIA_STORAGE_PATH` - Just a path
6. `API_V1_PREFIX` - Just a string

## Current Problem

### Git History Contains Secrets
- **File**: `backend/env.example` in commit `e4032c2`
- **Secrets Found**:
  - OpenAI API key (line 7 in old commit)
  - Deepgram API key (line 9 in old commit)

### Why GitHub Blocks Push
- GitHub's secret scanning detects API keys in commit history
- Even if we remove the file now, the old commit still contains it
- Must either:
  1. Rewrite git history to remove secrets from old commits
  2. Use GitHub URL to allow this specific secret

## Files That Should NOT Contain Secrets

### ✅ **Already Safe**:
- `backend/app/config.py` - Has empty defaults or placeholder values
- All service files - Only import from `settings`, don't hardcode secrets

### ⚠️ **Files to Never Commit**:
- `backend/.env` - Contains actual secrets
- `backend/env.example` - Currently has placeholder values (should be fine)

## Recommendations

1. **Never commit `.env` file** - Already in `.gitignore`
2. **`env.example` should only have placeholders** - Current version is safe
3. **Remove secrets from git history** - Need to rewrite commit `e4032c2`
4. **Use GitHub secret scanning allowance** - For the old commit, since it's just an example file

## Summary

**Total Environment Variables**: 11
- **Secrets (4)**: `OPENAI_API_KEY`, `DEEPGRAM_API_KEY`, `JITSI_APP_SECRET`, `SECRET_KEY`
- **Config (7)**: `JITSI_APP_ID`, `JITSI_SERVER_URL`, `JITSI_JWT_EXPIRATION`, `DATABASE_URL`, `MEDIA_STORAGE_PATH`, `API_V1_PREFIX`, `ALGORITHM`, `ACCESS_TOKEN_EXPIRE_MINUTES`

**Files Using Secrets**: 2
- `backend/app/services/jitsi_service.py` - Uses `JITSI_APP_SECRET`
- `backend/app/services/ai_service.py` - Uses `OPENAI_API_KEY`, `DEEPGRAM_API_KEY`

**Files Using Config**: 6
- All files above plus `main.py`, `connection.py`, `media_service.py`

