# Quote Widget App — Design Spec
**Date:** 2026-06-24  
**Status:** Approved  
**Platform:** Android + iOS  
**Framework:** Flutter (Dart) + native widget shells (Kotlin / Swift)

---

## Overview

A Flutter app that displays a random image with an overlaid quote — the spiritual successor to the KaiOS Nokia 8000 app in this repo. Available as a full-screen app and as a home screen widget on both Android and iOS. The widget is the primary surface. Images default to bundled anime/waifu art; users can supplement with their own photos. Quotes come from online APIs (anime + inspirational) with a bundled offline fallback. Built for personal use first, store-ready later.

---

## Architecture

Three layers:

```
┌─────────────────────────────────────┐
│         Flutter App (Dart)          │
│  • Main screen (full-screen img+quote) │
│  • Settings screen                  │
│  • QuoteService (API + cache)       │
│  • ImageService (bundled + gallery) │
│  • WidgetDataRepository             │
│  • RefreshScheduler (workmanager)   │
└──────────────┬──────────────────────┘
               │ home_widget (shared storage)
       ┌───────┴────────┐
       ▼                ▼
 Android Widget    iOS Widget
 (Kotlin/XML)    (Swift/WidgetKit)
 AppWidget +      TimelineProvider +
 WorkManager      BGAppRefreshTask
```

The Flutter app owns all business logic. Native widgets are read-only display shells — they read from shared storage and render. Widgets never fetch data independently; Flutter writes, widgets read.

---

## Screens

### Main Screen
- Full-screen image with quote text overlaid at the bottom
- Dark gradient scrim behind quote text for readability
- Tap anywhere → manual refresh (new random image + quote)
- Floating settings icon (bottom-right)
- Opens directly on launch — no splash, no onboarding

### Settings Screen
- **Refresh interval:** 15 / 30 / 60 / 120 min (default: 30)
- **Quote style:** Anime / Inspirational / Both (default: Both)
- **Images:** "Use my photos" toggle → gallery multi-select picker. Shows count of selected photos. "Reset to bundled images" option.
- **Widget preview:** static display of current image + quote as it appears on the widget

---

## Services

### QuoteService
- **Online sources:**
  - Anime: [animechan.io](https://animechan.io) API
  - Inspirational: [ZenQuotes API](https://zenquotes.io)
- **Offline fallback:** ~50 curated quotes compiled as `assets/quotes.json` (mix of both styles)
- Fetches batches of 10 quotes, stores in local `sqflite` cache
- Widget refresh always pulls from cache — no live network call at refresh time
- Cache refreshes opportunistically when app is foregrounded
- **First launch / empty cache:** falls back to bundled `quotes.json` immediately — no empty state

### ImageService
- **Bundled:** 33 images from the KaiOS `img/` folder, resized to max 1080px, included as Flutter assets
- **User photos:** selected via `image_picker`. App copies files to its documents directory (`path_provider`) so they persist if the originals move or are deleted. Paths stored in `shared_preferences`.
- **Pool:** at refresh time, picks randomly from combined pool (bundled + user). User photos are additive — they don't replace bundled images unless the user explicitly resets.

### WidgetDataRepository
Writes a single JSON blob to shared storage:
```json
{
  "imagePath": "...",
  "quote": "...",
  "author": "...",
  "source": "anime|inspirational|bundled",
  "timestamp": 1234567890
}
```
- Android: `home_widget` → SharedPreferences
- iOS: `home_widget` → App Groups UserDefaults

### RefreshScheduler
- **Android:** `workmanager` periodic task. Interval read from settings. Triggers `QuoteService` + `ImageService` → writes to `WidgetDataRepository` → calls `home_widget` update.
- **iOS:** WidgetKit `TimelineProvider` returns the next `TimelineEntry` at `now + interval`. Settings change calls `WidgetCenter.reloadAllTimelines()`.

---

## Widget

### Android
- **Small (2×2):** Full image background, quote overlaid with gradient scrim, author below
- **Medium (4×2):** Same layout, wider, slightly larger font

### iOS
- **Small:** Image background + short quote (truncated to 2 lines)
- **Medium:** Image + full quote + author
- **Large:** Image + full quote + author + app name watermark

Widget tap → deep links to Flutter app main screen.

**First widget render (before any refresh has run):** shows a random bundled image + a quote from `quotes.json`. Never blank.

---

## Project Structure

```
/                          ← repo root
├── kaios_version/         ← all original KaiOS files
│   ├── app.js
│   ├── index.html
│   ├── style.css
│   ├── manifest.webapp
│   ├── img/
│   ├── icons/
│   └── demo/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── main_screen.dart
│   │   └── settings_screen.dart
│   ├── services/
│   │   ├── quote_service.dart
│   │   ├── image_service.dart
│   │   └── refresh_scheduler.dart
│   ├── repositories/
│   │   └── widget_data_repository.dart
│   └── models/
│       ├── quote.dart
│       └── app_settings.dart
│
├── assets/
│   ├── images/            ← 33 resized KaiOS images
│   └── quotes.json        ← bundled fallback quotes (~50)
│
├── android/
│   └── app/src/main/
│       ├── kotlin/.../QuoteWidget.kt
│       └── res/layout/widget_quote.xml
│
├── ios/
│   └── QuoteWidget/
│       ├── QuoteWidget.swift
│       └── QuoteWidgetBundle.swift
│
├── pubspec.yaml
└── docs/superpowers/specs/
    └── 2026-06-24-quote-widget-app-design.md
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `home_widget` | Flutter ↔ native widget shared storage bridge |
| `workmanager` | Android background refresh scheduling |
| `sqflite` | Local quote cache |
| `http` | API calls |
| `image_picker` | User photo selection |
| `shared_preferences` | Settings + user image paths |
| `path_provider` | App documents directory for copied user images |

---

## Out of Scope (for now)
- User-defined custom quotes
- Cloud sync
- Notifications
- App Store / Play Store submission (personal use first)
- Waifu-specific API (images are local only for now)
- Multiple widget instances with different settings
