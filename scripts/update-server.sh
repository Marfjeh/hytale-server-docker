#!/bin/bash
set -e

cd /hytale-server

if [ ! -f "hytale-downloader" ]; then
    echo "Downloading hytale-downloader..."
    curl -sL https://downloader.hytale.com/hytale-downloader.zip -o hytale-downloader.zip
    unzip -q hytale-downloader.zip
    chmod +x hytale-downloader-linux-amd64 2>/dev/null || true
    mv hytale-downloader-linux-amd64 hytale-downloader
    rm -f hytale-downloader.zip hytale-downloader-windows-amd64.exe QUICKSTART.md
fi

chmod +x hytale-downloader 2>/dev/null || true

CURRENT_VERSION=""
if [ -f ".server_version" ]; then
    CURRENT_VERSION=$(cat .server_version)
    echo "Current version: $CURRENT_VERSION"
    echo "Checking for updates..."
    AVAILABLE_VERSION=$(./hytale-downloader -print-version 2>/dev/null || echo "unknown")
    
    if [ "$CURRENT_VERSION" = "$AVAILABLE_VERSION" ] && [ "$AVAILABLE_VERSION" != "unknown" ]; then
        echo "Already up to date (Version: $CURRENT_VERSION)"
        exit 0
    fi
    
    echo "Update available: $CURRENT_VERSION -> $AVAILABLE_VERSION"
    echo "Starting download of new version..."
else
    echo "First time setup - authentication required. Follow the browser prompt."
    echo "After logging in via the browser, the download will start automatically."
fi


./hytale-downloader -download-path game.zip
DOWNLOAD_EXIT=$?

if [ $DOWNLOAD_EXIT -ne 0 ]; then
    echo ""
    echo "ERROR: Download failed!"
    echo ""
    exit 1
fi

if [ ! -f "game.zip" ]; then
    echo "ERROR: Download file not found!"
    exit 1
fi

echo "Extracting server files..."
unzip -q -o game.zip

NEW_VERSION=$(./hytale-downloader -print-version 2>/dev/null || echo "unknown")

if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" != "$NEW_VERSION" ]; then
    echo "Version changed: $CURRENT_VERSION -> $NEW_VERSION"
    echo "Removing old AOT cache (will be regenerated)..."
    rm -f HytaleServer.aot
fi

echo "Installing server files..."
cp -f Server/HytaleServer.jar .
[ -f "Server/HytaleServer.aot" ] && cp -f Server/HytaleServer.aot .
[ -d "Server/Licenses" ] && rm -rf Licenses && cp -r Server/Licenses .

if [ ! -f "Assets.zip" ]; then
    echo "WARNING: Assets.zip not found in download!"
fi

rm -rf Server
rm -f game.zip

echo "$NEW_VERSION" > .server_version

echo "Server files installed successfully! (Version: $NEW_VERSION)"
