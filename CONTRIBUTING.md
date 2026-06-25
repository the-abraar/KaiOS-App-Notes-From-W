# Contributing to Glimps

This is a personal project, but ideas and contributions are genuinely welcome — especially if you're building something similar for someone you love.

---

## Philosophy

Glimps should feel **quiet and warm**. Every feature should pass this test: *does this make the experience more personal, or does it add noise?* If it adds noise, it probably doesn't belong here.

---

## Good first contributions

These are well-scoped, self-contained, and would make the app meaningfully better:

### Refresh on screen unlock
When the phone screen turns on, show a new photo (optional toggle, off by default).
- **Android:** register a `BroadcastReceiver` for `ACTION_USER_PRESENT` (unlock) or `ACTION_SCREEN_ON`
- **iOS:** WidgetKit doesn't expose unlock events directly — the workaround is setting a very short timeline refresh interval (e.g. 1 minute) when this mode is active
- Settings toggle: *"Change photo on every unlock"*

### Favourite photos
A heart icon overlay on the main screen. Favourited photos appear 3× more often in the random pool.
- Store favourites list in SharedPreferences
- Weighted random selection in `ImageService.getRandomImagePath()`

### Custom quotes
A simple text editor screen to write your own quotes. They go into a separate `user_quotes` SQLite table and are included in the rotation.
- Fits naturally inside `SettingsScreen` as a new section
- `DatabaseHelper` already has the infrastructure — just add the table and a CRUD UI

### Widget tap → specific screen
Currently widget tap opens the app main screen. Add deep link support so tapping the quote area opens a "quote detail" view.
- Uses `home_widget`'s `HomeWidget.widgetClicked` stream
- Already partially wired in the architecture

### Image crop/preview before adding
When a user picks a photo from gallery, show a preview/crop screen before saving. The current flow copies the full original.

---

## How to contribute

1. Fork the repo
2. Create a branch: `git checkout -b feature/your-idea`
3. Make your changes — keep them focused, one feature per PR
4. Test on a real device if possible (emulators don't support home screen widgets well)
5. Open a pull request with a short description of what it does and why

---

## Project structure

```
lib/
├── main.dart                          # App entry, init
├── screens/
│   ├── main_screen.dart               # Full-screen image + quote
│   └── settings_screen.dart           # Settings UI
├── services/
│   ├── quote_service.dart             # Fetches + caches quotes
│   ├── image_service.dart             # Manages bundled + user images
│   └── refresh_scheduler.dart         # workmanager background task
├── repositories/
│   └── widget_data_repository.dart    # Writes data to native widget
└── models/
    ├── quote.dart
    └── app_settings.dart

android/app/src/main/kotlin/com/the_abraar/quote_widget_app/
├── MainActivity.kt
└── QuoteWidgetProvider.kt             # Android widget renderer

ios/QuoteWidget/
└── QuoteWidget.swift                  # iOS WidgetKit extension
```

---

## Code style

- Dart: follow the existing style, `flutter analyze` should pass clean
- Kotlin/Swift: match the surrounding native code style
- No new dependencies without a good reason — the current stack is intentionally minimal

---

## Ideas that were considered and parked

- **Cloud sync / shared album** — needs a backend, which means accounts, which means complexity. Parked until there's a clean lightweight approach.
- **Notifications** — intentionally out of scope. Glimps is passive; it doesn't interrupt.
- **Social sharing** — not the point of this app.

---

## Questions

Open an issue or start a discussion. This is a small project — responses will be personal.
