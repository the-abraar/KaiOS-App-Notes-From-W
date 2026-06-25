# ShifaTifa — Setup & Run Guide

> Personal reference. Everything needed to build and run on iOS and Android from a Mac.

---

## App Identity

| | |
|---|---|
| **Display name** | ShifaTifa |
| **Bundle / App ID** | `com.the_abraar.quote_widget_app` |
| **iOS App Group** | `group.com.the_abraar.quote_widget_app` |
| **iOS Widget kind** | `QuoteWidget` |
| **iOS Widget bundle ID** | `com.the_abraar.quote_widget_app.QuoteWidget` |
| **Android widget class** | `.QuoteWidgetProvider` |
| **Min iOS** | 14.0 |
| **Min Android SDK** | 21 |

---

## Prerequisites

Install these once on your Mac if not already present.

### Flutter
```bash
# Check if installed
flutter --version

# If not: https://docs.flutter.dev/get-started/install/macos
# After install, accept licenses:
flutter doctor --android-licenses
flutter doctor
```

### CocoaPods
```bash
sudo gem install cocoapods
# or via Homebrew:
brew install cocoapods
```

### Xcode
Install from the App Store. Then:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```

### Android (optional — only needed for Android)
Install Android Studio from https://developer.android.com/studio  
During setup, install the Android SDK. Flutter uses the SDK, not the IDE.

---

## One-time repo setup

```bash
cd ~/Everything/personal/FlutterClaude/KaiOS-App-Notes-From-W

# Install Flutter dependencies
flutter pub get

# Install iOS CocoaPods dependencies
cd ios && pod install && cd ..
```

> If `flutter pub get` fails on `home_widget`, change the version in `pubspec.yaml` to the latest shown at https://pub.dev/packages/home_widget and re-run.

---

## iOS Setup (do once in Xcode)

### Step 1 — Open the workspace (NOT the .xcodeproj)
```bash
open ios/Runner.xcworkspace
```

### Step 2 — Set your signing team for Runner

1. Click **Runner** in the left sidebar → select the **Runner** target
2. **Signing & Capabilities** tab
3. Set **Team** to your Apple Developer account
4. **Bundle Identifier**: confirm it says `com.the_abraar.quote_widget_app`

### Step 3 — Enable App Group on Runner

Still on **Runner → Signing & Capabilities**:
1. Click **+ Capability** → search **App Groups** → add it
2. Click **+** under App Groups → enter: `group.com.the_abraar.quote_widget_app`
3. Xcode will auto-create/register this group with your Apple account

### Step 4 — Add the Widget Extension target

1. **File → New → Target**
2. Choose **Widget Extension** → click Next
3. Fill in:
   - **Product Name**: `QuoteWidget`
   - **Team**: your Apple Developer account
   - **Bundle Identifier**: `com.the_abraar.quote_widget_app.QuoteWidget`
   - **Language**: Swift
   - Uncheck **Include Configuration App Intent**
4. Click **Finish** → when prompted "Activate QuoteWidget scheme?" → click **Activate**

### Step 5 — Replace generated Swift files with our code

Xcode will have generated placeholder files in the `QuoteWidget` folder. Replace them:

1. In Xcode's left sidebar, expand **QuoteWidget**
2. Delete all `.swift` files Xcode generated (right-click → Delete → Move to Trash)
3. Drag `ios/QuoteWidget/QuoteWidget.swift` from Finder into the **QuoteWidget** group in Xcode
   - When prompted: check **Copy items if needed** → **Add to QuoteWidget target only** (not Runner)

Or via command line, open the file directly — Xcode sees it because it's inside the `ios/QuoteWidget/` folder already:
```bash
# The file is already at:
ls ios/QuoteWidget/QuoteWidget.swift
# Just add it to the target in Xcode by dragging it into the QuoteWidget group
```

### Step 6 — Set App Group on QuoteWidget target

1. Click the **QuoteWidget** target in Xcode
2. **Signing & Capabilities** tab
3. Set **Team** to your Apple Developer account
4. Bundle Identifier: `com.the_abraar.quote_widget_app.QuoteWidget`
5. Click **+ Capability** → **App Groups** → add `group.com.the_abraar.quote_widget_app`

### Step 7 — Set entitlements file for QuoteWidget target

1. **QuoteWidget target → Build Settings**
2. Search `entitlements`
3. Set **Code Signing Entitlements** to: `QuoteWidget/QuoteWidget.entitlements`

Alternatively, Xcode may create its own entitlements file. If it does, open it and make sure it contains:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.the_abraar.quote_widget_app</string>
</array>
```

### Step 8 — Re-run pod install

After adding the widget target:
```bash
cd ios && pod install && cd ..
```

### Step 9 — Run on your iPhone

Connect your iPhone via USB. Trust the Mac if prompted on the phone.

```bash
# List connected devices
flutter devices

# Run (replace <device-id> with the ID shown above, e.g. "00008120-...")
flutter run -d <device-id>

# Or just:
flutter run
# Flutter will pick the connected iPhone automatically if it's the only device
```

First run will extract bundled images to the app's documents directory. The main screen should show a quote over an anime image.

---

## iOS Widget — Add to Home Screen

1. Long-press the home screen → tap **+** (top left)
2. Search **ShifaTifa**
3. Choose size (Small / Medium / Large) → tap **Add Widget**
4. The widget shows a placeholder quote on first add
5. Open the app → it refreshes → go back to home screen → widget updates with image + quote

**Widget auto-refreshes** every 30 minutes (configurable in the app's Settings screen).

---

## Android Setup

### Enable USB debugging on your Android phone

1. **Settings → About phone** → tap **Build number** 7 times → Developer Options unlocked
2. **Settings → Developer options** → enable **USB debugging**
3. Connect phone to Mac via USB → tap **Allow** on the phone

### Run on Android

```bash
# Confirm device is visible
flutter devices

# Run
flutter run
```

> Android debug builds are signed with the debug keystore automatically. No extra config needed for personal use.

### Android Widget — Add to Home Screen

1. Long-press the home screen → **Widgets**
2. Scroll to find **ShifaTifa** (or search)
3. Long-press the widget → drag to home screen
4. On first add it shows: *"Tap the app to load a quote."*
5. Open the app once → widget populates with image + quote
6. After that, `workmanager` refreshes it every 30 minutes in the background

---

## App Settings

Inside the app (tap the gear icon bottom-right):

| Setting | Options | Default |
|---|---|---|
| Refresh interval | 15 / 30 / 60 / 120 min | 30 min |
| Quote style | Anime / Inspirational / Both | Both |
| Images | Add from gallery / Reset to bundled | Bundled |

Tap anywhere on the main screen for an instant manual refresh.

---

## Building a Release APK (Android)

For a release APK to install without a computer:
```bash
flutter build apk --release

# Output:
# build/app/outputs/flutter-apk/app-release.apk

# Install directly to connected phone:
adb install build/app/outputs/flutter-apk/app-release.apk
```

> Release builds use the debug signing key by default (fine for personal use). For Play Store, you'd add a proper `keystore` — out of scope for now.

---

## Building for iOS TestFlight / Ad Hoc

```bash
flutter build ios --release
```

Then in Xcode: **Product → Archive → Distribute App**.

---

## Troubleshooting

### "No devices found"
- iPhone: check **Settings → Privacy → Developer Mode** is on (iOS 16+)
- Android: re-plug USB, check USB mode is "File transfer" not "Charging only"
- Run `flutter doctor` and fix any flagged issues

### Widget shows blank / "Tap app to load"
- Open the app at least once — it extracts bundled images and writes initial widget data
- If still blank: tap anywhere on the main screen to force a refresh

### `pod install` fails
```bash
cd ios
pod repo update
pod install
```

### `flutter pub get` fails on `home_widget`
Check the latest version at https://pub.dev/packages/home_widget and update `pubspec.yaml`:
```yaml
home_widget: ^0.9.2   # use whatever is latest
```

### App crashes on launch (black screen)
All init steps are wrapped in try-catch so this shouldn't block the UI. If it still happens:
1. Run `flutter run` from terminal and read the console output
2. Most likely cause: Xcode signing not configured (see iOS Step 2)
3. Or App Group not added to both targets (see iOS Steps 3 and 6)

### Xcode signing error "No profiles for ... found"
- Make sure your Apple ID is added in **Xcode → Settings → Accounts**
- Set Team on both **Runner** and **QuoteWidget** targets
- Try **Product → Clean Build Folder** then re-run

### `flutter: MissingPluginException` for home_widget
Run:
```bash
cd ios && pod install && cd ..
flutter run
```

---

## File Structure Quick Reference

```
KaiOS-App-Notes-From-W/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── screens/main_screen.dart           # Full-screen image + quote
│   ├── screens/settings_screen.dart       # Settings UI
│   ├── services/quote_service.dart        # API fetch + bundled fallback
│   ├── services/image_service.dart        # Image management
│   ├── services/refresh_scheduler.dart    # workmanager periodic task
│   ├── repositories/widget_data_repository.dart  # home_widget bridge
│   └── models/                            # Quote, AppSettings
├── assets/
│   ├── images/1.jpg … 33.jpg             # Bundled anime images
│   └── quotes.json                        # 50 offline fallback quotes
├── android/app/src/main/kotlin/com/the_abraar/quote_widget_app/
│   ├── MainActivity.kt
│   └── QuoteWidgetProvider.kt             # Android home screen widget
├── ios/
│   ├── Runner.xcworkspace                 # ← always open this, not .xcodeproj
│   ├── Runner/Runner.entitlements         # App Group for Runner
│   └── QuoteWidget/
│       ├── QuoteWidget.swift              # iOS WidgetKit extension
│       └── QuoteWidget.entitlements       # App Group for widget
└── kaios_version/                         # Original Nokia KaiOS app (archived)
```
