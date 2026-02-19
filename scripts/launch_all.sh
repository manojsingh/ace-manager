#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Ace Manager Environment..."

# 1. Update Dependencies
echo "📦 Updating dependencies..."
flutter pub get

# 2. Launch Emulators
echo "📱 Launching Android Emulator (Pixel 9 Pro XL)..."
flutter emulators --launch Pixel_9_Pro_XL &

echo "🍎 Launching iOS Simulator..."
# Using open -a Simulator is often more reliable on Mac to bring it to front
open -a Simulator &
# Alternatively: flutter emulators --launch apple_ios_simulator

# 3. Wait for devices to be ready (optional, but helps 'flutter run -d all' pick them up)
echo "⏳ Waiting for devices to connect..."
sleep 10

# 4. Run on All Devices
echo "▶️  Running app on all active devices..."
flutter run -d all
