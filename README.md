<div align="center">

# 💕 Glimps

### *She's the first thing you see.*

A home screen widget that puts a photo of your person — and a quote that feels like it was written for the two of you — right where you look a hundred times a day.

Available for **Android** and **iOS**, as a full-screen app and a native home screen widget.

---

![Glimps Widget Preview](docs/assets/preview.png)

</div>

---

## What it does

Every time you glance at your phone, Glimps is there — a photo of her, a quote that hits, no distractions. It refreshes quietly in the background so it always feels fresh.

- **Home screen widget** — small, medium, or large. Always on. Always her.
- **Full-screen view** — tap the widget to open the app and see it full bleed
- **Tap to refresh** — new photo, new quote, instantly
- **Your photos** — add her photos (or yours together) from your gallery
- **Quote styles** — anime quotes, classic love and wisdom quotes, or both
- **Configurable refresh** — every 15, 30, 60, or 120 minutes
- **Offline-first** — 33 bundled images and 50 curated quotes work with no internet

---

## The story

This started as a KaiOS app for a Nokia 8000 4G — a tiny phone running a web-based OS, showing waifu images and anime quotes. The original lives in [`kaios_version/`](kaios_version/).

It grew into something more personal. The phone changed. The feeling didn't.

---

## Getting started

See [`INSTRUCTIONS.md`](INSTRUCTIONS.md) for the full setup guide — prerequisites, iOS Xcode steps, Android USB setup, widget installation, and troubleshooting.

```bash
git clone https://github.com/the-abraar/shifatifa_glimps
cd shifatifa_glimps
flutter pub get
flutter run
```

---

## Roadmap

Things coming next — see [`CONTRIBUTING.md`](CONTRIBUTING.md) if you want to help build any of these.

### Near term
- [x] **Refresh on every unlock** — Android: shows a new photo each time you unlock, with a Settings toggle to turn it on/off
- [ ] **Favourite photos** — mark certain photos to appear more often
- [ ] **Quote editor** — write your own quotes that only you two will ever see
- [ ] **Widget themes** — gradient colours, font choices, dark/light scrim intensity

### Bigger ideas
- [ ] **Anniversary & date countdowns** — a subtle "Day 847" or "3 months until her birthday" line on the widget
- [ ] **Shared mode** — she installs it too; you both see the same rotating set of photos from a shared album
- [ ] **Morning message** — a special first-unlock quote each morning, different from the rest
- [ ] **Memory mode** — on dates that matter (first date, birthday) the widget surfaces a photo from that day
- [ ] **Lock screen widget** — iOS 16+ / Android 13+ lock screen support
- [ ] **iPad / tablet layout** — wider widget sizes with side-by-side photo and quote

---

## Built with

| | |
|---|---|
| Flutter | Cross-platform app |
| Kotlin | Android AppWidget |
| Swift / WidgetKit | iOS home screen widget |
| home_widget | Flutter ↔ native widget bridge |
| workmanager | Android background refresh |
| sqflite | Local quote cache |

---

## License

MIT — do whatever you want with it. Just keep it loving.

---

<div align="center">

*Made for W. 💛*

</div>
