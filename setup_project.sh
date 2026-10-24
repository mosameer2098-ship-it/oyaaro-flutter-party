#!/usr/bin/env bash
# Ek baar chalayein. Ye Flutter project banata hai, code copy karta hai,
# permissions add karta hai, aur Firebase configure karta hai.
set -e

PROJECT_NAME=voice_party
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter install nahi hai. https://docs.flutter.dev/get-started/install se install karein."
  exit 1
fi

if [ ! -d "$PROJECT_NAME/android" ]; then
  flutter create "$PROJECT_NAME" --org com.example
fi

cp -r "$SRC_DIR/lib" "$PROJECT_NAME/"
cp "$SRC_DIR/pubspec.yaml" "$PROJECT_NAME/"
cp -r "$SRC_DIR/assets" "$PROJECT_NAME/"
cp "$SRC_DIR/analysis_options.yaml" "$PROJECT_NAME/"
mkdir -p "$PROJECT_NAME/firebase"
cp "$SRC_DIR/firebase/firestore.rules" "$PROJECT_NAME/firebase/"

MANIFEST="$PROJECT_NAME/android/app/src/main/AndroidManifest.xml"
if ! grep -q "RECORD_AUDIO" "$MANIFEST"; then
  # <manifest ...> tag ke turant baad permissions insert karein
  sed -i '/<manifest /a\    <uses-permission android:name="android.permission.INTERNET" />\n    <uses-permission android:name="android.permission.RECORD_AUDIO" />\n    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />\n    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />\n    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />' "$MANIFEST"
fi

cd "$PROJECT_NAME"
flutter pub get

echo ""
echo "Ab Firebase configure karein (login karke project chunein):"
echo "  dart pub global activate flutterfire_cli"
echo "  flutterfire configure"
echo ""
echo "Phir lib/zego_voice_service.dart mein appId aur appSign daalein, aur"
echo "firebase/firestore.rules ko Firebase Console mein paste karein."
echo "Run karne ke liye: flutter run"
