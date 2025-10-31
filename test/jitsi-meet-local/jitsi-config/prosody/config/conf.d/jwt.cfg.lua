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
