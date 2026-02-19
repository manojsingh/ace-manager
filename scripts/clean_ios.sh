#!/bin/bash

echo "🧹 Starting Deep Clean for iOS..."

# 1. Clean Flutter artifacts
echo "1️⃣  Running flutter clean..."
flutter clean

# 2. Remove iOS specific dependency locks and pods
echo "2️⃣  Removing ios/Pods and Podfile.lock..."
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf ios/Flutter/Flutter.framework
rm -rf ios/Flutter/App.framework

# 3. Get Flutter packages
echo "3️⃣  Running flutter pub get..."
flutter pub get

# 4. Install Pods
echo "4️⃣  Installing CocoaPods..."
cd ios
pod install --repo-update
cd ..

echo "✅ Deep Clean Complete! Try running your app now."
