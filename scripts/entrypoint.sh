#!/bin/sh
set -e

echo "Starting Hytale Server..."

if [ ! -f "HytaleServer.jar" ] || [ ! -f "Assets.zip" ]; then
    echo "Server files not found. Downloading latest version..."
    if [ -x "/scripts/update-server.sh" ]; then
        /scripts/update-server.sh || {
            echo "ERROR: Failed to download server files!"
            exit 1
        }
    fi
elif [ "$AUTO_UPDATE" = "true" ]; then
    echo "Checking for server updates..."
    if [ -x "/scripts/update-server.sh" ]; then
        /scripts/update-server.sh || echo "Update check failed, continuing with existing files..."
    fi
fi

mkdir -p logs mods universe .cache

if [ ! -f "config.json" ]; then
    echo "Creating default config.json..."
    cat > config.json << 'EOF'
{
  "Version": 3,
  "ServerName": "Hytale Server",
  "MOTD": "",
  "Password": "",
  "MaxPlayers": 100,
  "MaxViewRadius": 32,
  "LocalCompressionEnabled": false,
  "Defaults": {
    "World": "default",
    "GameMode": "Adventure"
  },
  "ConnectionTimeouts": {
    "JoinTimeouts": {}
  },
  "RateLimit": {},
  "Modules": {},
  "LogLevels": {},
  "Mods": {},
  "DisplayTmpTagsInStrings": false,
  "PlayerStorage": {
    "Type": "Hytale"
  }
}
EOF
fi

if [ ! -f "bans.json" ]; then
    echo "[]" > bans.json
fi

if [ ! -f "whitelist.json" ]; then
    echo "[]" > whitelist.json
fi

if [ ! -f "permissions.json" ]; then
    cat > permissions.json << 'EOF'
{
  "users": {},
  "groups": {
    "Default": [],
    "OP": ["*"]
  }
}
EOF
fi

if [ -n "$SERVER_NAME" ] || [ -n "$MOTD" ] || [ -n "$PASSWORD" ] || [ -n "$MAX_PLAYERS" ] || [ -n "$MAX_VIEW_RADIUS" ]; then
    echo "Applying environment variable configuration..."
    /scripts/update-config.sh
fi

JAVA_ARGS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

if [ -f "HytaleServer.aot" ]; then
    JAVA_ARGS="$JAVA_ARGS -XX:AOTCache=HytaleServer.aot"
fi

SERVER_ARGS="--assets Assets.zip"

if [ "$ENABLE_BACKUPS" = "true" ]; then
    BACKUP_DIR="${BACKUP_DIR:-/hytale-server/backups}"
    BACKUP_FREQ="${BACKUP_FREQUENCY:-30}"
    SERVER_ARGS="$SERVER_ARGS --backup --backup-dir $BACKUP_DIR --backup-frequency $BACKUP_FREQ"
fi

if [ "$DISABLE_SENTRY" = "true" ]; then
    SERVER_ARGS="$SERVER_ARGS --disable-sentry"
fi

if [ -n "$BIND_ADDRESS" ]; then
    SERVER_ARGS="$SERVER_ARGS --bind $BIND_ADDRESS"
else
    SERVER_ARGS="$SERVER_ARGS --bind 0.0.0.0:5520"
fi

exec java $JAVA_ARGS -jar HytaleServer.jar $SERVER_ARGS
