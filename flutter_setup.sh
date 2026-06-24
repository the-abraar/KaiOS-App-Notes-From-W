#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO_DIR"

echo "=== Quote Widget App Setup ==="
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Install from https://docs.flutter.dev/get-started/install"
    exit 1
fi

echo "Flutter found: $(flutter --version | head -1)"
echo ""

# Step 1: Create Flutter project (preserves existing files)
echo "Step 1: Scaffolding Flutter project..."
flutter create . --org com.inovacetech --project-name quote_widget_app --platforms android,ios 2>&1 | grep -v "^$" || true
echo "Done."
echo ""

# Step 2: Flutter pub get
echo "Step 2: Installing dependencies..."
flutter pub get
echo "Done."
echo ""

# Step 3: Patch AndroidManifest.xml - add permissions
echo "Step 3: Patching AndroidManifest.xml..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if grep -q "android.permission.INTERNET" "$MANIFEST"; then
    echo "  Permissions already present, skipping."
else
    # Insert permissions before <application
    python3 - <<'PYEOF'
import re

with open('android/app/src/main/AndroidManifest.xml', 'r') as f:
    content = f.read()

permissions = '''    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
'''

content = content.replace('    <application', permissions + '    <application', 1)

with open('android/app/src/main/AndroidManifest.xml', 'w') as f:
    f.write(content)
print("  Permissions added.")
PYEOF
fi

# Step 4: Add widget receiver to AndroidManifest.xml
if grep -q "QuoteWidgetProvider" "$MANIFEST"; then
    echo "  Widget receiver already present, skipping."
else
    python3 - <<'PYEOF'
import re

with open('android/app/src/main/AndroidManifest.xml', 'r') as f:
    content = f.read()

widget_receiver = '''
        <receiver
            android:name=".QuoteWidgetProvider"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/widget_quote_info" />
        </receiver>'''

# Insert before </application>
content = content.replace('    </application>', widget_receiver + '\n    </application>', 1)

with open('android/app/src/main/AndroidManifest.xml', 'w') as f:
    f.write(content)
print("  Widget receiver added.")
PYEOF
fi
echo "Done."
echo ""

# Step 5: Patch iOS Info.plist - add photo permissions
echo "Step 4: Patching ios/Runner/Info.plist..."
INFOPLIST="ios/Runner/Info.plist"
if grep -q "NSPhotoLibraryUsageDescription" "$INFOPLIST"; then
    echo "  Photo permissions already present, skipping."
else
    python3 - <<'PYEOF'
with open('ios/Runner/Info.plist', 'r') as f:
    content = f.read()

photo_keys = '''	<key>NSPhotoLibraryUsageDescription</key>
	<string>Select photos to use as widget backgrounds.</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>Save images to your photo library.</string>
'''

# Insert before </dict>
content = content.replace('</dict>\n</plist>', photo_keys + '</dict>\n</plist>', 1)

with open('ios/Runner/Info.plist', 'w') as f:
    f.write(content)
print("  Photo permissions added.")
PYEOF
fi
echo "Done."
echo ""

echo "=== Setup complete! ==="
echo ""
echo "NEXT STEPS:"
echo "1. Run: flutter run (to test the app)"
echo ""
echo "2. For ANDROID widget: Build APK and add widget to home screen:"
echo "   flutter build apk --debug"
echo "   adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "3. For iOS widget: Open ios/Runner.xcworkspace in Xcode:"
echo "   a. File → New → Target → Widget Extension"
echo "   b. Name: QuoteWidget, Bundle ID: com.inovacetech.quotewidget.QuoteWidget"
echo "   c. Uncheck 'Include Configuration App Intent' → Finish"
echo "   d. Replace generated Swift files with ios/QuoteWidget/QuoteWidget.swift"
echo "   e. Runner target → Signing & Capabilities → App Groups → add group.com.inovacetech.quotewidget"
echo "   f. QuoteWidget target → Signing & Capabilities → App Groups → add group.com.inovacetech.quotewidget"
echo "   g. Build & run on physical device"
echo ""
echo "4. Run tests: flutter test"
