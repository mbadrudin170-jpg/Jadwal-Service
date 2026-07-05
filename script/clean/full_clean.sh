#!/bin/bash

echo "🛑 Stopping Gradle daemons..."
(cd android && chmod +x gradlew && ./gradlew --stop)

echo "🧹 Running flutter clean..."
flutter clean

echo "🗑️ Removing local build artifacts..."
rm -rf build/ .dart_tool/ android/.gradle/ android/app/build/
rm -f .flutter-plugins .flutter-plugins-dependencies

echo "⚙️ Cleaning Gradle caches..."
rm -rf ~/.gradle/caches/ ~/.gradle/wrapper/dists/*

echo "📦 Cleaning pub cache..."
rm -rf ~/.pub-cache/

echo "🌐 Cleaning global caches (.cache)..."
rm -rf ~/.cache/*

echo "🗑️ Cleaning Dart server cache..."
rm -rf ~/.dartServer

echo "❄️ Running Nix Garbage Collector (IDX System Optimization)..."
command -v nix-store &>/dev/null && nix-store --gc && nix-store --optimise

echo "⚡ Fetching fresh dependencies for this project..."
flutter pub upgrade

echo "🔨 Re-running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

echo "📊 Remaining disk space:"
df -h