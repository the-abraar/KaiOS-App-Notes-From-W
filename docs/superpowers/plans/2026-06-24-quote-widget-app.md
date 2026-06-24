# Quote Widget App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Flutter app for Android and iOS that shows a random image with a quote, available as a full-screen app and native home screen widgets that refresh every 30 minutes.

**Architecture:** Flutter app owns all logic (quote fetching, image management, refresh scheduling) and writes current image+quote to shared storage via `home_widget`. Native widget shells (Android AppWidget + iOS WidgetKit) read from shared storage and render. `workmanager` drives background refresh on Android; WidgetKit's `TimelineProvider` drives refresh on iOS.

**Tech Stack:** Flutter/Dart 3.0+, Kotlin (Android widget), Swift 5.9+ (iOS WidgetKit), home_widget ^2.0.0, workmanager ^0.5.2, sqflite ^2.3.3, http ^1.2.2, image_picker ^1.1.2, shared_preferences ^2.3.2, path_provider ^2.1.4

## Global Constraints

- App ID: `com.inovacetech.quotewidget`
- App Group ID (iOS): `group.com.inovacetech.quotewidget`
- Android widget provider class: `QuoteWidgetProvider`
- iOS widget kind: `QuoteWidget`
- SharedPrefs key — widget data: `widget_data`
- SharedPrefs key — refresh interval: `refresh_interval_minutes`
- SharedPrefs key — quote style: `quote_style` (values: `anime`, `inspirational`, `both`)
- SharedPrefs key — user image paths: `user_image_paths`
- Default refresh interval: `30`
- Anime quotes API: `https://animechan.io/api/v1/quotes/random`
- General quotes API: `https://zenquotes.io/api/random`
- Min Flutter SDK: 3.0.0 / Min Android SDK: 21 / Min iOS: 14.0
- workmanager task name: `com.inovacetech.quotewidget.refresh`
- All image files shared with widget stored in external files dir (Android) / App Group container (iOS)

---

### Task 1: Move KaiOS files and scaffold Flutter project

**Files:**
- Create: `kaios_version/` (directory)
- Create: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`

**Interfaces:**
- Produces: working `flutter run` scaffold with all dependencies declared

- [ ] **Step 1: Move KaiOS files**

```bash
cd /path/to/repo
mkdir kaios_version
git mv app.js index.html style.css manifest.webapp LICENSE README.md kaios_version/
git mv img icons demo kaios_version/
git commit -m "chore: move KaiOS files to kaios_version/"
```

- [ ] **Step 2: Create Flutter project over existing directory**

```bash
flutter create . --org com.inovacetech --project-name quote_widget_app --platforms android,ios
```

- [ ] **Step 3: Replace pubspec.yaml with full dependencies**

```yaml
name: quote_widget_app
description: Random image and quote app with home screen widget.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  home_widget: ^2.0.0
  workmanager: ^0.5.2
  sqflite: ^2.3.3
  http: ^1.2.2
  image_picker: ^1.1.2
  shared_preferences: ^2.3.2
  path_provider: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/quotes.json
    - assets/images/
```

- [ ] **Step 4: Run pub get**

```bash
flutter pub get
```

Expected: no errors, `pubspec.lock` created.

- [ ] **Step 5: Add Android permissions to AndroidManifest.xml**

Add inside `<manifest>`, before `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
```

- [ ] **Step 6: Add iOS permissions to Info.plist**

Add inside the root `<dict>`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos to use as widget backgrounds.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save images to your photo library.</string>
```

- [ ] **Step 7: Verify Flutter runs**

```bash
flutter run
```

Expected: default Flutter counter app launches on device/emulator.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: scaffold Flutter project with dependencies"
```

---

### Task 2: Bundled assets — quotes.json and images

**Files:**
- Create: `assets/quotes.json`
- Create: `assets/images/` (copy + resize KaiOS images)

**Interfaces:**
- Produces: `assets/quotes.json` — array of `{text, author, source, character?, anime?}` objects
- Produces: `assets/images/1.jpg` … `assets/images/33.jpg`

- [ ] **Step 1: Create assets directories**

```bash
mkdir -p assets/images
```

- [ ] **Step 2: Copy and resize KaiOS images**

```bash
# Requires ImageMagick: brew install imagemagick  or  sudo apt install imagemagick
for i in $(seq 1 33); do
  convert kaios_version/img/$i.jpg -resize '1080x1920>' -quality 85 assets/images/$i.jpg
done
```

Expected: 33 files in `assets/images/`, each ≤ 1080px wide.

- [ ] **Step 3: Create assets/quotes.json**

```json
[
  {"text":"Whatever you lose, you'll find it again. But what you throw away you'll never get back.","author":"Kenshin Himura","source":"bundled","anime":"Rurouni Kenshin"},
  {"text":"People's lives don't end when they die. It ends when they lose faith.","author":"Itachi Uchiha","source":"bundled","anime":"Naruto"},
  {"text":"The world is cruel, but also beautiful.","author":"Mikasa Ackerman","source":"bundled","anime":"Attack on Titan"},
  {"text":"A dropout will beat a genius through hard work.","author":"Rock Lee","source":"bundled","anime":"Naruto"},
  {"text":"If you don't take risks, you can't create a future.","author":"Monkey D. Luffy","source":"bundled","anime":"One Piece"},
  {"text":"Hard work is worthless for those that don't believe in themselves.","author":"Naruto Uzumaki","source":"bundled","anime":"Naruto"},
  {"text":"Push through the pain. Giving up hurts more.","author":"Vegeta","source":"bundled","anime":"Dragon Ball Z"},
  {"text":"Fear is not evil. It tells you what your weakness is.","author":"Gildarts Clive","source":"bundled","anime":"Fairy Tail"},
  {"text":"The moment you give up is the moment you let someone else win.","author":"Koro-sensei","source":"bundled","anime":"Assassination Classroom"},
  {"text":"There are no regrets. If one can be proud of one's life, one should not wish for another chance.","author":"Saber","source":"bundled","anime":"Fate/Stay Night"},
  {"text":"Don't give up, there's no shame in falling down! True shame is to not stand up again!","author":"Shintaro Midorima","source":"bundled","anime":"Kuroko's Basketball"},
  {"text":"Life is not a game of luck. If you wanna win, work hard.","author":"Sora","source":"bundled","anime":"No Game No Life"},
  {"text":"I'll leave tomorrow's problems to tomorrow's me.","author":"Saitama","source":"bundled","anime":"One Punch Man"},
  {"text":"Being lonely is more painful than getting hurt.","author":"Monkey D. Luffy","source":"bundled","anime":"One Piece"},
  {"text":"Reject common sense to make the impossible possible.","author":"Simon","source":"bundled","anime":"Gurren Lagann"},
  {"text":"If you keep on crying, I'll never be able to leave.","author":"Himura Kenshin","source":"bundled","anime":"Rurouni Kenshin"},
  {"text":"Life is not a game of luck. If you wanna win, work hard.","author":"Sora","source":"bundled","anime":"No Game No Life"},
  {"text":"A lesson without pain is meaningless. That's because no one can gain without sacrificing something.","author":"Edward Elric","source":"bundled","anime":"Fullmetal Alchemist"},
  {"text":"To know sorrow is not terrifying. What is terrifying is to know you can't go back to happiness you could have.","author":"Matsumoto Rangiku","source":"bundled","anime":"Bleach"},
  {"text":"The only one who can beat me is me.","author":"Taiga Kagami","source":"bundled","anime":"Kuroko's Basketball"},
  {"text":"If you don't share someone's pain, you can never understand them.","author":"Nagato","source":"bundled","anime":"Naruto"},
  {"text":"It's okay not to be okay as long as you are not giving up.","author":"Karen Araragi","source":"bundled","anime":"Monogatari Series"},
  {"text":"Even if I'm worthless and carry demon blood... I refuse to let my comrades die!","author":"Inuyasha","source":"bundled","anime":"Inuyasha"},
  {"text":"Power comes in response to a need, not a desire.","author":"Goku","source":"bundled","anime":"Dragon Ball Z"},
  {"text":"A place where someone still thinks about you is a place you can call home.","author":"Jiraiya","source":"bundled","anime":"Naruto"},
  {"text":"The only way to do great work is to love what you do.","author":"Steve Jobs","source":"bundled"},
  {"text":"In the middle of every difficulty lies opportunity.","author":"Albert Einstein","source":"bundled"},
  {"text":"It does not matter how slowly you go as long as you do not stop.","author":"Confucius","source":"bundled"},
  {"text":"The future belongs to those who believe in the beauty of their dreams.","author":"Eleanor Roosevelt","source":"bundled"},
  {"text":"Success is not final, failure is not fatal: it is the courage to continue that counts.","author":"Winston Churchill","source":"bundled"},
  {"text":"You miss 100% of the shots you don't take.","author":"Wayne Gretzky","source":"bundled"},
  {"text":"Whether you think you can or you think you can't, you're right.","author":"Henry Ford","source":"bundled"},
  {"text":"The best time to plant a tree was 20 years ago. The second best time is now.","author":"Chinese Proverb","source":"bundled"},
  {"text":"An unexamined life is not worth living.","author":"Socrates","source":"bundled"},
  {"text":"Don't judge each day by the harvest you reap but by the seeds that you plant.","author":"Robert Louis Stevenson","source":"bundled"},
  {"text":"The people who are crazy enough to think they can change the world are the ones who do.","author":"Steve Jobs","source":"bundled"},
  {"text":"Life is what happens when you're busy making other plans.","author":"John Lennon","source":"bundled"},
  {"text":"We may encounter many defeats but we must not be defeated.","author":"Maya Angelou","source":"bundled"},
  {"text":"In the end, it's not the years in your life that count. It's the life in your years.","author":"Abraham Lincoln","source":"bundled"},
  {"text":"Never let the fear of striking out keep you from playing the game.","author":"Babe Ruth","source":"bundled"},
  {"text":"Life is either a daring adventure or nothing at all.","author":"Helen Keller","source":"bundled"},
  {"text":"Many of life's failures are people who did not realize how close they were to success when they gave up.","author":"Thomas Edison","source":"bundled"},
  {"text":"You have brains in your head. You have feet in your shoes. You can steer yourself any direction you choose.","author":"Dr. Seuss","source":"bundled"},
  {"text":"If you look at what you have in life, you'll always have more.","author":"Oprah Winfrey","source":"bundled"},
  {"text":"Life is not measured by the number of breaths we take, but by the moments that take our breath away.","author":"Maya Angelou","source":"bundled"},
  {"text":"The mind is everything. What you think you become.","author":"Buddha","source":"bundled"},
  {"text":"An eye for an eye will only make the whole world blind.","author":"Mahatma Gandhi","source":"bundled"},
  {"text":"Darkness cannot drive out darkness; only light can do that.","author":"Martin Luther King Jr.","source":"bundled"},
  {"text":"We accept the love we think we deserve.","author":"Stephen Chbosky","source":"bundled"},
  {"text":"It always seems impossible until it's done.","author":"Nelson Mandela","source":"bundled"},
  {"text":"Believe you can and you're halfway there.","author":"Theodore Roosevelt","source":"bundled"}
]
```

- [ ] **Step 4: Verify asset count**

```bash
echo "Images: $(ls assets/images/*.jpg | wc -l)"
echo "Quotes: $(python3 -c "import json; print(len(json.load(open('assets/quotes.json'))))")"
```

Expected: `Images: 33`, `Quotes: 50`

- [ ] **Step 5: Commit**

```bash
git add assets/
git commit -m "feat: add bundled images and quotes.json"
```

---

### Task 3: Data models

**Files:**
- Create: `lib/models/quote.dart`
- Create: `lib/models/app_settings.dart`
- Create: `test/models/quote_test.dart`
- Create: `test/models/app_settings_test.dart`

**Interfaces:**
- Produces: `Quote` — `{String text, String author, String source, String? character, String? anime}` with `fromJson`/`toJson`
- Produces: `AppSettings` — `{int refreshIntervalMinutes, QuoteStyle quoteStyle, List<String> userImagePaths}` with `fromJson`/`toJson`
- Produces: `enum QuoteStyle { anime, inspirational, both }`

- [ ] **Step 1: Write failing model tests**

`test/models/quote_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_widget_app/models/quote.dart';

void main() {
  group('Quote', () {
    test('fromJson parses anime quote', () {
      final json = {
        'text': 'Never give up!',
        'author': 'Naruto',
        'source': 'bundled',
        'anime': 'Naruto',
      };
      final quote = Quote.fromJson(json);
      expect(quote.text, 'Never give up!');
      expect(quote.author, 'Naruto');
      expect(quote.source, 'bundled');
      expect(quote.anime, 'Naruto');
      expect(quote.character, isNull);
    });

    test('toJson round-trips', () {
      final quote = Quote(
        text: 'Test',
        author: 'Author',
        source: 'anime',
      );
      expect(Quote.fromJson(quote.toJson()).text, 'Test');
    });
  });
}
```

`test/models/app_settings_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:quote_widget_app/models/app_settings.dart';

void main() {
  group('AppSettings', () {
    test('defaults are correct', () {
      const s = AppSettings();
      expect(s.refreshIntervalMinutes, 30);
      expect(s.quoteStyle, QuoteStyle.both);
      expect(s.userImagePaths, isEmpty);
    });

    test('fromJson round-trips', () {
      const s = AppSettings(
        refreshIntervalMinutes: 60,
        quoteStyle: QuoteStyle.anime,
        userImagePaths: ['/path/img.jpg'],
      );
      final s2 = AppSettings.fromJson(s.toJson());
      expect(s2.refreshIntervalMinutes, 60);
      expect(s2.quoteStyle, QuoteStyle.anime);
      expect(s2.userImagePaths, ['/path/img.jpg']);
    });
  });
}
```

- [ ] **Step 2: Run tests — verify they fail**

```bash
flutter test test/models/
```

Expected: compilation errors (files don't exist yet).

- [ ] **Step 3: Create lib/models/quote.dart**

```dart
class Quote {
  final String text;
  final String author;
  final String source; // 'anime' | 'inspirational' | 'bundled'
  final String? character;
  final String? anime;

  const Quote({
    required this.text,
    required this.author,
    required this.source,
    this.character,
    this.anime,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: json['text'] as String,
        author: json['author'] as String,
        source: json['source'] as String,
        character: json['character'] as String?,
        anime: json['anime'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'source': source,
        if (character != null) 'character': character,
        if (anime != null) 'anime': anime,
      };
}
```

- [ ] **Step 4: Create lib/models/app_settings.dart**

```dart
enum QuoteStyle { anime, inspirational, both }

class AppSettings {
  final int refreshIntervalMinutes;
  final QuoteStyle quoteStyle;
  final List<String> userImagePaths;

  const AppSettings({
    this.refreshIntervalMinutes = 30,
    this.quoteStyle = QuoteStyle.both,
    this.userImagePaths = const [],
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        refreshIntervalMinutes: json['refreshIntervalMinutes'] as int? ?? 30,
        quoteStyle: QuoteStyle.values.firstWhere(
          (e) => e.name == (json['quoteStyle'] as String? ?? 'both'),
          orElse: () => QuoteStyle.both,
        ),
        userImagePaths: (json['userImagePaths'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'refreshIntervalMinutes': refreshIntervalMinutes,
        'quoteStyle': quoteStyle.name,
        'userImagePaths': userImagePaths,
      };

  AppSettings copyWith({
    int? refreshIntervalMinutes,
    QuoteStyle? quoteStyle,
    List<String>? userImagePaths,
  }) =>
      AppSettings(
        refreshIntervalMinutes:
            refreshIntervalMinutes ?? this.refreshIntervalMinutes,
        quoteStyle: quoteStyle ?? this.quoteStyle,
        userImagePaths: userImagePaths ?? this.userImagePaths,
      );
}
```

- [ ] **Step 5: Run tests — verify they pass**

```bash
flutter test test/models/
```

Expected: All tests pass.

- [ ] **Step 6: Commit**

```bash
git add lib/models/ test/models/
git commit -m "feat: add Quote and AppSettings models"
```

---

### Task 4: Database helper (quote cache)

**Files:**
- Create: `lib/services/database_helper.dart`
- Create: `test/services/database_helper_test.dart`

**Interfaces:**
- Consumes: `Quote` from `lib/models/quote.dart`
- Produces: `DatabaseHelper.instance` singleton
- Produces: `Future<void> insertQuotes(List<Quote> quotes)`
- Produces: `Future<List<Quote>> getQuotesBySource(String source)` — source: `'anime'`, `'inspirational'`, or `'all'`
- Produces: `Future<void> clearQuotesBySource(String source)`

- [ ] **Step 1: Write failing tests**

`test/services/database_helper_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:quote_widget_app/models/quote.dart';
import 'package:quote_widget_app/services/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper db;

    setUp(() async {
      db = DatabaseHelper.forTesting();
      await db.database;
    });

    tearDown(() async {
      await db.close();
    });

    test('inserts and retrieves quotes by source', () async {
      final quotes = [
        const Quote(text: 'Q1', author: 'A1', source: 'anime'),
        const Quote(text: 'Q2', author: 'A2', source: 'inspirational'),
      ];
      await db.insertQuotes(quotes);
      final anime = await db.getQuotesBySource('anime');
      expect(anime.length, 1);
      expect(anime.first.text, 'Q1');
    });

    test('getQuotesBySource all returns all quotes', () async {
      await db.insertQuotes([
        const Quote(text: 'Q1', author: 'A1', source: 'anime'),
        const Quote(text: 'Q2', author: 'A2', source: 'inspirational'),
      ]);
      final all = await db.getQuotesBySource('all');
      expect(all.length, 2);
    });

    test('clearQuotesBySource removes only that source', () async {
      await db.insertQuotes([
        const Quote(text: 'Q1', author: 'A1', source: 'anime'),
        const Quote(text: 'Q2', author: 'A2', source: 'inspirational'),
      ]);
      await db.clearQuotesBySource('anime');
      final remaining = await db.getQuotesBySource('all');
      expect(remaining.length, 1);
      expect(remaining.first.source, 'inspirational');
    });
  });
}
```

- [ ] **Step 2: Add sqflite_common_ffi to dev_dependencies for tests**

Add to `pubspec.yaml` dev_dependencies:
```yaml
  sqflite_common_ffi: ^2.3.4
```

Run: `flutter pub get`

- [ ] **Step 3: Run tests — verify they fail**

```bash
flutter test test/services/database_helper_test.dart
```

Expected: compilation error.

- [ ] **Step 4: Create lib/services/database_helper.dart**

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quote.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static const _dbName = 'quotes.db';
  static const _tableName = 'quotes';

  Database? _database;
  final String? _testPath;

  DatabaseHelper._internal() : _testPath = null;
  DatabaseHelper._forTesting() : _testPath = inMemoryDatabasePath;

  factory DatabaseHelper.forTesting() => DatabaseHelper._forTesting();

  Future<Database> get database async {
    _database ??= await _initDb();
    return _database!;
  }

  Future<void> close() async => (await database).close();

  Future<Database> _initDb() async {
    final path = _testPath ?? join(await getDatabasesPath(), _dbName);
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        author TEXT NOT NULL,
        source TEXT NOT NULL,
        character TEXT,
        anime TEXT,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertQuotes(List<Quote> quotes) async {
    final db = await database;
    final batch = db.batch();
    for (final q in quotes) {
      batch.insert(_tableName, {
        'text': q.text,
        'author': q.author,
        'source': q.source,
        'character': q.character,
        'anime': q.anime,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Quote>> getQuotesBySource(String source) async {
    final db = await database;
    final rows = source == 'all'
        ? await db.query(_tableName)
        : await db.query(_tableName, where: 'source = ?', whereArgs: [source]);
    return rows.map((r) => Quote.fromJson(r)).toList();
  }

  Future<void> clearQuotesBySource(String source) async {
    final db = await database;
    await db.delete(_tableName, where: 'source = ?', whereArgs: [source]);
  }
}
```

- [ ] **Step 5: Run tests — verify they pass**

```bash
flutter test test/services/database_helper_test.dart
```

Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add lib/services/database_helper.dart test/services/database_helper_test.dart pubspec.yaml pubspec.lock
git commit -m "feat: add DatabaseHelper for quote cache"
```

---

### Task 5: QuoteService

**Files:**
- Create: `lib/services/quote_service.dart`
- Create: `test/services/quote_service_test.dart`
- Create: `test/services/quote_service_test.mocks.dart` (generated)

**Interfaces:**
- Consumes: `DatabaseHelper.instance`, `AppSettings` from models
- Produces: `Future<Quote> getRandomQuote(QuoteStyle style)` — returns from cache, falls back to bundled
- Produces: `Future<void> refreshCache(QuoteStyle style)` — fetches from API, stores in DB

- [ ] **Step 1: Generate mocks**

Create `test/services/quote_service_test.dart` (before implementation, for mock generation):
```dart
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:quote_widget_app/services/database_helper.dart';

@GenerateMocks([http.Client, DatabaseHelper])
void main() {}
```

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: `test/services/quote_service_test.mocks.dart` created.

- [ ] **Step 2: Write failing tests**

Replace `test/services/quote_service_test.dart`:
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:quote_widget_app/models/app_settings.dart';
import 'package:quote_widget_app/models/quote.dart';
import 'package:quote_widget_app/services/quote_service.dart';
import 'quote_service_test.mocks.dart';

void main() {
  late MockClient mockHttp;
  late MockDatabaseHelper mockDb;
  late QuoteService service;

  setUp(() {
    mockHttp = MockClient();
    mockDb = MockDatabaseHelper();
    service = QuoteService(httpClient: mockHttp, db: mockDb);
  });

  group('getRandomQuote', () {
    test('returns from cache when quotes exist', () async {
      const cached = [Quote(text: 'Cached', author: 'A', source: 'anime')];
      when(mockDb.getQuotesBySource('all')).thenAnswer((_) async => cached);
      final q = await service.getRandomQuote(QuoteStyle.both);
      expect(q.text, 'Cached');
      verifyNever(mockHttp.get(any));
    });

    test('falls back to bundled when cache empty and API fails', () async {
      when(mockDb.getQuotesBySource(any)).thenAnswer((_) async => []);
      when(mockHttp.get(any)).thenThrow(Exception('Network error'));
      final q = await service.getRandomQuote(QuoteStyle.both);
      expect(q.source, 'bundled');
    });
  });

  group('refreshCache', () {
    test('parses animechan response and stores quotes', () async {
      when(mockDb.clearQuotesBySource('anime')).thenAnswer((_) async {});
      when(mockDb.insertQuotes(any)).thenAnswer((_) async {});
      when(mockHttp.get(Uri.parse('https://animechan.io/api/v1/quotes/random')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'status': 'success',
                  'data': {
                    'content': 'Test quote',
                    'character': {'name': 'Naruto', 'anime': {'name': 'Naruto'}},
                  }
                }),
                200,
              ));
      await service.refreshCache(QuoteStyle.anime);
      final captured = verify(mockDb.insertQuotes(captureAny)).captured.first;
      expect((captured as List<Quote>).first.text, 'Test quote');
    });
  });
}
```

- [ ] **Step 3: Run tests — verify they fail**

```bash
flutter test test/services/quote_service_test.dart
```

Expected: compilation error.

- [ ] **Step 4: Create lib/services/quote_service.dart**

```dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/app_settings.dart';
import '../models/quote.dart';
import 'database_helper.dart';

class QuoteService {
  static const _animechanUrl = 'https://animechan.io/api/v1/quotes/random';
  static const _zenquotesUrl = 'https://zenquotes.io/api/random';

  final http.Client _httpClient;
  final DatabaseHelper _db;
  List<Quote>? _bundledQuotes;

  QuoteService({http.Client? httpClient, DatabaseHelper? db})
      : _httpClient = httpClient ?? http.Client(),
        _db = db ?? DatabaseHelper.instance;

  Future<List<Quote>> _loadBundled() async {
    _bundledQuotes ??= await rootBundle
        .loadString('assets/quotes.json')
        .then((s) => (jsonDecode(s) as List)
            .map((e) => Quote.fromJson(e as Map<String, dynamic>))
            .toList());
    return _bundledQuotes!;
  }

  Future<Quote> getRandomQuote(QuoteStyle style) async {
    final sourceFilter = style == QuoteStyle.both
        ? 'all'
        : style == QuoteStyle.anime
            ? 'anime'
            : 'inspirational';

    final cached = await _db.getQuotesBySource(sourceFilter);
    if (cached.isNotEmpty) {
      return cached[Random().nextInt(cached.length)];
    }

    // Cache empty — try API refresh, fall back to bundled
    try {
      await refreshCache(style);
      final fresh = await _db.getQuotesBySource(sourceFilter);
      if (fresh.isNotEmpty) return fresh[Random().nextInt(fresh.length)];
    } catch (_) {}

    final bundled = await _loadBundled();
    final filtered = style == QuoteStyle.both
        ? bundled
        : bundled.where((q) => q.source == 'bundled').toList();
    return filtered[Random().nextInt(filtered.length)];
  }

  Future<void> refreshCache(QuoteStyle style) async {
    if (style == QuoteStyle.anime || style == QuoteStyle.both) {
      await _fetchAndStore(_animechanUrl, 'anime', _parseAnimechan);
    }
    if (style == QuoteStyle.inspirational || style == QuoteStyle.both) {
      await _fetchAndStore(_zenquotesUrl, 'inspirational', _parseZenquotes);
    }
  }

  Future<void> _fetchAndStore(
    String url,
    String source,
    List<Quote> Function(dynamic) parser,
  ) async {
    final response = await _httpClient.get(Uri.parse(url));
    if (response.statusCode != 200) return;
    final quotes = parser(jsonDecode(response.body));
    if (quotes.isEmpty) return;
    await _db.clearQuotesBySource(source);
    await _db.insertQuotes(quotes);
  }

  List<Quote> _parseAnimechan(dynamic json) {
    if (json is Map && json['status'] == 'success') {
      final data = json['data'] as Map<String, dynamic>;
      return [
        Quote(
          text: data['content'] as String,
          author: (data['character'] as Map)['name'] as String,
          source: 'anime',
          character: (data['character'] as Map)['name'] as String,
          anime: ((data['character'] as Map)['anime'] as Map)['name'] as String,
        )
      ];
    }
    return [];
  }

  List<Quote> _parseZenquotes(dynamic json) {
    if (json is List && json.isNotEmpty) {
      return [
        Quote(
          text: json[0]['q'] as String,
          author: json[0]['a'] as String,
          source: 'inspirational',
        )
      ];
    }
    return [];
  }
}
```

- [ ] **Step 5: Run tests — verify they pass**

```bash
flutter test test/services/quote_service_test.dart
```

Expected: All pass.

- [ ] **Step 6: Commit**

```bash
git add lib/services/quote_service.dart test/services/
git commit -m "feat: add QuoteService with API fetch and bundled fallback"
```

---

### Task 6: ImageService

**Files:**
- Create: `lib/services/image_service.dart`
- Create: `test/services/image_service_test.dart`

**Interfaces:**
- Consumes: `AppSettings.userImagePaths`
- Produces: `Future<void> initBundledImages()` — extracts assets to external files dir on first run
- Produces: `Future<String> getRandomImagePath(List<String> userPaths)` — returns absolute file path
- Produces: `Future<String> copyUserImage(String sourcePath)` — copies to shared dir, returns new path
- Produces: `Future<String> getSharedImagesDir()` — platform-appropriate shared directory

- [ ] **Step 1: Write failing tests**

`test/services/image_service_test.dart`:
```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:quote_widget_app/services/image_service.dart';

class FakePathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getExternalStoragePath() async => Directory.systemTemp.path;
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      Directory.systemTemp.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = FakePathProvider();
  });

  group('ImageService', () {
    test('getRandomImagePath returns from combined pool', () async {
      // Create fake files
      final dir = Directory.systemTemp.createTempSync('img_test');
      final f1 = File('${dir.path}/a.jpg')..writeAsBytesSync([]);
      final f2 = File('${dir.path}/b.jpg')..writeAsBytesSync([]);
      final service = ImageService.forTesting(sharedDir: dir.path);
      final path =
          await service.getRandomImagePath([f1.path, f2.path]);
      expect([f1.path, f2.path], contains(path));
      dir.deleteSync(recursive: true);
    });

    test('getRandomImagePath falls back to bundled when user list empty',
        () async {
      final dir = Directory.systemTemp.createTempSync('img_test2');
      final f1 = File('${dir.path}/1.jpg')..writeAsBytesSync([]);
      final service = ImageService.forTesting(sharedDir: dir.path);
      final path = await service.getRandomImagePath([]);
      expect(path, contains('.jpg'));
      dir.deleteSync(recursive: true);
    });
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/services/image_service_test.dart
```

Expected: compilation error.

- [ ] **Step 3: Create lib/services/image_service.dart**

```dart
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ImageService {
  static const _bundledCount = 33;
  static const _prefsKeyInitDone = 'bundled_images_extracted';

  final String? _testSharedDir;

  ImageService() : _testSharedDir = null;
  ImageService.forTesting({required String sharedDir})
      : _testSharedDir = sharedDir;

  Future<String> getSharedImagesDir() async {
    if (_testSharedDir != null) return _testSharedDir!;
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      final path = '${dir!.path}/images';
      await Directory(path).create(recursive: true);
      return path;
    } else {
      // iOS: use app documents dir (App Group set up in Task 13)
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/images';
      await Directory(path).create(recursive: true);
      return path;
    }
  }

  Future<void> initBundledImages() async {
    final sharedDir = await getSharedImagesDir();
    for (var i = 1; i <= _bundledCount; i++) {
      final dest = File('$sharedDir/bundled_$i.jpg');
      if (!dest.existsSync()) {
        final data = await rootBundle.load('assets/images/$i.jpg');
        await dest.writeAsBytes(data.buffer.asUint8List());
      }
    }
  }

  Future<List<String>> _getBundledPaths() async {
    final sharedDir = await getSharedImagesDir();
    return List.generate(
      _bundledCount,
      (i) => '$sharedDir/bundled_${i + 1}.jpg',
    ).where((p) => File(p).existsSync()).toList();
  }

  Future<String> getRandomImagePath(List<String> userPaths) async {
    final bundled = await _getBundledPaths();
    final pool = [...bundled, ...userPaths.where((p) => File(p).existsSync())];
    if (pool.isEmpty) return bundled.isNotEmpty ? bundled.first : '';
    return pool[Random().nextInt(pool.length)];
  }

  Future<String> copyUserImage(String sourcePath) async {
    final sharedDir = await getSharedImagesDir();
    final fileName = 'user_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File('$sharedDir/$fileName');
    await File(sourcePath).copy(dest.path);
    return dest.path;
  }
}
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
flutter test test/services/image_service_test.dart
```

Expected: All pass.

- [ ] **Step 5: Commit**

```bash
git add lib/services/image_service.dart test/services/image_service_test.dart
git commit -m "feat: add ImageService for bundled and user images"
```

---

### Task 7: WidgetDataRepository

**Files:**
- Create: `lib/repositories/widget_data_repository.dart`
- Create: `test/repositories/widget_data_repository_test.dart`

**Interfaces:**
- Consumes: `Quote`, `String imagePath`
- Produces: `Future<void> saveAndUpdate(Quote quote, String imagePath)` — writes JSON to shared storage and triggers widget refresh
- Produces: `Future<Map<String, dynamic>?> load()` — reads current widget data

- [ ] **Step 1: Write failing test**

`test/repositories/widget_data_repository_test.dart`:
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quote_widget_app/models/quote.dart';
import 'package:quote_widget_app/repositories/widget_data_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WidgetDataRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveAndUpdate writes correct JSON to prefs', () async {
      final repo = WidgetDataRepository.forTesting();
      const quote = Quote(text: 'Hello', author: 'World', source: 'bundled');
      await repo.saveAndUpdate(quote, '/path/img.jpg');
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('widget_data');
      expect(raw, isNotNull);
      final json = jsonDecode(raw!) as Map<String, dynamic>;
      expect(json['quote'], 'Hello');
      expect(json['author'], 'World');
      expect(json['imagePath'], '/path/img.jpg');
    });

    test('load returns null when no data saved', () async {
      final repo = WidgetDataRepository.forTesting();
      final data = await repo.load();
      expect(data, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test — verify it fails**

```bash
flutter test test/repositories/widget_data_repository_test.dart
```

Expected: compilation error.

- [ ] **Step 3: Create lib/repositories/widget_data_repository.dart**

```dart
import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class WidgetDataRepository {
  static const _key = 'widget_data';
  static const _androidName = 'QuoteWidgetProvider';
  static const _iosName = 'QuoteWidget';

  final bool _testing;
  WidgetDataRepository() : _testing = false;
  WidgetDataRepository.forTesting() : _testing = true;

  Future<void> saveAndUpdate(Quote quote, String imagePath) async {
    final payload = jsonEncode({
      'quote': quote.text,
      'author': quote.author,
      'source': quote.source,
      'imagePath': imagePath,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    if (_testing) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, payload);
      return;
    }

    await HomeWidget.saveWidgetData<String>(_key, payload);
    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: _iosName,
    );
  }

  Future<Map<String, dynamic>?> load() async {
    if (_testing) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
    }
    final raw = await HomeWidget.getWidgetData<String>(_key);
    return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
  }
}
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
flutter test test/repositories/widget_data_repository_test.dart
```

Expected: All pass.

- [ ] **Step 5: Commit**

```bash
git add lib/repositories/ test/repositories/
git commit -m "feat: add WidgetDataRepository"
```

---

### Task 8: RefreshScheduler

**Files:**
- Create: `lib/services/refresh_scheduler.dart`

**Interfaces:**
- Consumes: `QuoteService`, `ImageService`, `WidgetDataRepository`, `AppSettings`
- Produces: `Future<void> RefreshScheduler.init()` — registers workmanager callback (call once at app start)
- Produces: `Future<void> RefreshScheduler.schedule(int intervalMinutes)` — registers/updates periodic task
- Produces: `Future<void> RefreshScheduler.runOnce()` — immediate refresh (used by tap and by workmanager callback)
- Produces top-level function: `callbackDispatcher()` — required by workmanager

- [ ] **Step 1: Create lib/services/refresh_scheduler.dart**

(No unit tests for this service — it wraps platform APIs that require device execution; tested via integration test in Task 12.)

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../models/app_settings.dart';
import '../repositories/widget_data_repository.dart';
import 'image_service.dart';
import 'quote_service.dart';

const _taskName = 'com.inovacetech.quotewidget.refresh';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      await _doRefresh();
    }
    return true;
  });
}

Future<void> _doRefresh() async {
  final prefs = await SharedPreferences.getInstance();
  final styleStr = prefs.getString('quote_style') ?? 'both';
  final style = QuoteStyle.values.firstWhere(
    (e) => e.name == styleStr,
    orElse: () => QuoteStyle.both,
  );
  final userPaths = prefs.getStringList('user_image_paths') ?? [];

  final quoteService = QuoteService();
  final imageService = ImageService();
  final repo = WidgetDataRepository();

  final quote = await quoteService.getRandomQuote(style);
  final imagePath = await imageService.getRandomImagePath(userPaths);
  await repo.saveAndUpdate(quote, imagePath);
}

class RefreshScheduler {
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  }

  static Future<void> schedule(int intervalMinutes) async {
    await Workmanager().cancelByUniqueName(_taskName);
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> runOnce() async {
    await _doRefresh();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/services/refresh_scheduler.dart
git commit -m "feat: add RefreshScheduler with workmanager"
```

---

### Task 9: MainScreen

**Files:**
- Create: `lib/screens/main_screen.dart`

**Interfaces:**
- Consumes: `QuoteService`, `ImageService`, `WidgetDataRepository`, `AppSettings` (from SharedPreferences)
- Produces: `MainScreen` widget — stateful, full-screen image + quote, tap to refresh, settings FAB

- [ ] **Step 1: Create lib/screens/main_screen.dart**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/quote.dart';
import '../repositories/widget_data_repository.dart';
import '../services/image_service.dart';
import '../services/quote_service.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _quoteService = QuoteService();
  final _imageService = ImageService();
  final _repo = WidgetDataRepository();

  String? _imagePath;
  Quote? _quote;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<AppSettings> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final styleStr = prefs.getString('quote_style') ?? 'both';
    final userPaths = prefs.getStringList('user_image_paths') ?? [];
    return AppSettings(
      quoteStyle: QuoteStyle.values.firstWhere(
        (e) => e.name == styleStr,
        orElse: () => QuoteStyle.both,
      ),
      userImagePaths: userPaths,
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final settings = await _loadSettings();
      final quote = await _quoteService.getRandomQuote(settings.quoteStyle);
      final imagePath =
          await _imageService.getRandomImagePath(settings.userImagePaths);
      await _repo.saveAndUpdate(quote, imagePath);
      setState(() {
        _quote = quote;
        _imagePath = imagePath;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _loading ? null : _refresh,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_imagePath != null && File(_imagePath!).existsSync())
              Image.file(
                File(_imagePath!),
                fit: BoxFit.cover,
              )
            else
              const ColoredBox(color: Colors.black),
            if (_loading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (!_loading && _quote != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${_quote!.text}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${_quote!.author}${_quote!.anime != null ? ', ${_quote!.anime}' : ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                  _refresh();
                },
                backgroundColor: Colors.white.withOpacity(0.15),
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/screens/main_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/main_screen.dart
git commit -m "feat: add MainScreen with full-screen image and quote overlay"
```

---

### Task 10: SettingsScreen

**Files:**
- Create: `lib/screens/settings_screen.dart`

**Interfaces:**
- Consumes: `SharedPreferences`, `ImageService.copyUserImage`, `RefreshScheduler.schedule`
- Produces: `SettingsScreen` widget — refresh interval picker, quote style picker, image management

- [ ] **Step 1: Create lib/screens/settings_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../services/image_service.dart';
import '../services/refresh_scheduler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _imageService = ImageService();
  final _picker = ImagePicker();

  int _intervalMinutes = 30;
  QuoteStyle _quoteStyle = QuoteStyle.both;
  List<String> _userImagePaths = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _intervalMinutes = prefs.getInt('refresh_interval_minutes') ?? 30;
      _quoteStyle = QuoteStyle.values.firstWhere(
        (e) => e.name == (prefs.getString('quote_style') ?? 'both'),
        orElse: () => QuoteStyle.both,
      );
      _userImagePaths = prefs.getStringList('user_image_paths') ?? [];
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('refresh_interval_minutes', _intervalMinutes);
    await prefs.setString('quote_style', _quoteStyle.name);
    await prefs.setStringList('user_image_paths', _userImagePaths);
    await RefreshScheduler.schedule(_intervalMinutes);
  }

  Future<void> _addPhotos() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final newPaths = <String>[];
    for (final img in picked) {
      final copied = await _imageService.copyUserImage(img.path);
      newPaths.add(copied);
    }
    setState(() => _userImagePaths.addAll(newPaths));
    await _save();
  }

  Future<void> _resetImages() async {
    setState(() => _userImagePaths = []);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionLabel('Refresh Interval'),
                ...([15, 30, 60, 120].map((m) => RadioListTile<int>(
                      title: Text('$m minutes',
                          style: const TextStyle(color: Colors.white)),
                      value: m,
                      groupValue: _intervalMinutes,
                      activeColor: Colors.white,
                      onChanged: (v) async {
                        setState(() => _intervalMinutes = v!);
                        await _save();
                      },
                    ))),
                const Divider(color: Colors.white24),
                _SectionLabel('Quote Style'),
                ...QuoteStyle.values.map((style) => RadioListTile<QuoteStyle>(
                      title: Text(
                          style.name[0].toUpperCase() + style.name.substring(1),
                          style: const TextStyle(color: Colors.white)),
                      value: style,
                      groupValue: _quoteStyle,
                      activeColor: Colors.white,
                      onChanged: (v) async {
                        setState(() => _quoteStyle = v!);
                        await _save();
                      },
                    )),
                const Divider(color: Colors.white24),
                _SectionLabel('Images'),
                ListTile(
                  leading:
                      const Icon(Icons.add_photo_alternate, color: Colors.white),
                  title: Text(
                    _userImagePaths.isEmpty
                        ? 'Add photos from gallery'
                        : 'Add more photos (${_userImagePaths.length} selected)',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: _addPhotos,
                ),
                if (_userImagePaths.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.white54),
                    title: const Text('Reset to bundled images',
                        style: TextStyle(color: Colors.white54)),
                    onTap: _resetImages,
                  ),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 1.2)),
      );
}
```

- [ ] **Step 2: Verify it compiles**

```bash
flutter analyze lib/screens/settings_screen.dart
```

Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/screens/settings_screen.dart
git commit -m "feat: add SettingsScreen"
```

---

### Task 11: Wire up main.dart

**Files:**
- Modify: `lib/main.dart`

**Interfaces:**
- Consumes: all services, screens
- Produces: runnable app, RefreshScheduler initialized, bundled images extracted on first launch

- [ ] **Step 1: Replace lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'services/image_service.dart';
import 'services/refresh_scheduler.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HomeWidget.setAppGroupId('group.com.inovacetech.quotewidget');
  await RefreshScheduler.init();

  // Extract bundled images to shared dir on first run
  await ImageService().initBundledImages();

  // Schedule default refresh if not yet scheduled
  await RefreshScheduler.schedule(30);

  runApp(const QuoteWidgetApp());
}

class QuoteWidgetApp extends StatelessWidget {
  const QuoteWidgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote Widget',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(),
      ),
      home: const MainScreen(),
    );
  }
}
```

- [ ] **Step 2: Run the app**

```bash
flutter run
```

Expected: app launches, shows a quote overlaid on an image from `assets/images/`.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: wire up main.dart with initialization"
```

---

### Task 12: Android home screen widget

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Create: `android/app/src/main/kotlin/com/inovacetech/quotewidget/QuoteWidgetProvider.kt`
- Create: `android/app/src/main/res/layout/widget_quote.xml`
- Create: `android/app/src/main/res/xml/widget_quote_info.xml`
- Create: `android/app/src/main/res/drawable/widget_background.xml`

**Interfaces:**
- Consumes: `SharedPreferences` key `widget_data` (written by `WidgetDataRepository`)
- Produces: Android 2×2 home screen widget showing image + quote

- [ ] **Step 1: Create widget background drawable**

`android/app/src/main/res/drawable/widget_background.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android"
    android:shape="rectangle">
    <corners android:radius="16dp" />
    <solid android:color="#CC000000" />
</shape>
```

- [ ] **Step 2: Create widget AppWidget info**

`android/app/src/main/res/xml/widget_quote_info.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:minWidth="110dp"
    android:minHeight="110dp"
    android:targetCellWidth="2"
    android:targetCellHeight="2"
    android:updatePeriodMillis="0"
    android:initialLayout="@layout/widget_quote"
    android:resizeMode="horizontal|vertical"
    android:widgetCategory="home_screen" />
```

- [ ] **Step 3: Create widget layout**

`android/app/src/main/res/layout/widget_quote.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:id="@+id/widget_container"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <ImageView
        android:id="@+id/widget_image"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        android:scaleType="centerCrop"
        android:contentDescription="@null" />

    <LinearLayout
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:layout_gravity="bottom"
        android:orientation="vertical"
        android:background="#99000000"
        android:padding="8dp">

        <TextView
            android:id="@+id/widget_quote_text"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#FFFFFF"
            android:textSize="11sp"
            android:maxLines="3"
            android:ellipsize="end"
            android:fontFamily="serif"
            android:textStyle="italic"
            android:text="Loading..." />

        <TextView
            android:id="@+id/widget_author_text"
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:textColor="#CCFFFFFF"
            android:textSize="9sp"
            android:layout_marginTop="2dp"
            android:text="" />
    </LinearLayout>
</FrameLayout>
```

- [ ] **Step 4: Create QuoteWidgetProvider.kt**

`android/app/src/main/kotlin/com/inovacetech/quotewidget/QuoteWidgetProvider.kt`:
```kotlin
package com.inovacetech.quotewidget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.widget.RemoteViews
import org.json.JSONObject

class QuoteWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { id ->
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {
        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences", Context.MODE_PRIVATE
            )
            val raw = prefs.getString("flutter.widget_data", null)

            val views = RemoteViews(context.packageName, R.layout.widget_quote)

            if (raw != null) {
                runCatching {
                    val json = JSONObject(raw)
                    val quote = json.getString("quote")
                    val author = json.getString("author")
                    val imagePath = json.getString("imagePath")

                    views.setTextViewText(R.id.widget_quote_text, "“$quote”")
                    views.setTextViewText(R.id.widget_author_text, "— $author")

                    val bitmap = BitmapFactory.decodeFile(imagePath)
                    if (bitmap != null) {
                        views.setImageViewBitmap(R.id.widget_image, bitmap)
                    }
                }
            } else {
                views.setTextViewText(R.id.widget_quote_text, "“Tap the app to load a quote.”")
                views.setTextViewText(R.id.widget_author_text, "")
            }

            // Tap widget → open app
            val intent = Intent(context, MainActivity::class.java)
            val pending = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, pending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
```

- [ ] **Step 5: Register widget in AndroidManifest.xml**

Add inside `<application>`, after the existing `<activity>` block:
```xml
<receiver
    android:name=".QuoteWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_quote_info" />
</receiver>
```

- [ ] **Step 6: Build and verify**

```bash
flutter build apk --debug
```

Expected: build succeeds with no Kotlin errors.

- [ ] **Step 7: Test on device — add widget to home screen**

1. Install: `flutter run`
2. Long-press home screen → Widgets → find "Quote Widget" → add
3. Widget should show "Tap the app to load a quote." on first add
4. Open app (triggers refresh) → return to home screen → widget shows image + quote

- [ ] **Step 8: Commit**

```bash
git add android/
git commit -m "feat: add Android home screen widget"
```

---

### Task 13: iOS WidgetKit extension

**Files:**
- Create: `ios/QuoteWidget/QuoteWidget.swift`
- Create: `ios/QuoteWidget/QuoteWidgetBundle.swift`
- Modify: `ios/Runner.xcodeproj` (via Xcode — add widget extension target)
- Modify: `ios/Runner/Runner.entitlements` (App Group)
- Create: `ios/QuoteWidget/QuoteWidget.entitlements`

**Interfaces:**
- Consumes: App Groups UserDefaults key `widget_data` (written by `WidgetDataRepository` via `home_widget`)
- Produces: iOS Small/Medium/Large widget showing image + quote

- [ ] **Step 1: Add App Group entitlement to Runner**

Open `ios/Runner/Runner.entitlements` (create if missing):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.inovacetech.quotewidget</string>
    </array>
</dict>
</plist>
```

- [ ] **Step 2: Add Widget Extension target in Xcode**

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target → Widget Extension
3. Name: `QuoteWidget`
4. Product Name: `QuoteWidget`
5. Bundle ID: `com.inovacetech.quotewidget.QuoteWidget`
6. Uncheck "Include Configuration App Intent"
7. Click Finish → Activate scheme when prompted
8. In the QuoteWidget target → Signing & Capabilities → + Capability → App Groups → add `group.com.inovacetech.quotewidget`
9. In the Runner target → Signing & Capabilities → App Groups → add same group

- [ ] **Step 3: Create QuoteWidget.entitlements**

`ios/QuoteWidget/QuoteWidget.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.inovacetech.quotewidget</string>
    </array>
</dict>
</plist>
```

- [ ] **Step 4: Replace generated QuoteWidget.swift**

`ios/QuoteWidget/QuoteWidget.swift`:
```swift
import WidgetKit
import SwiftUI

struct WidgetData {
    let quote: String
    let author: String
    let imagePath: String?

    static let placeholder = WidgetData(
        quote: "The only way to do great work is to love what you do.",
        author: "Steve Jobs",
        imagePath: nil
    )

    static func load() -> WidgetData {
        guard
            let defaults = UserDefaults(suiteName: "group.com.inovacetech.quotewidget"),
            let raw = defaults.string(forKey: "widget_data"),
            let data = raw.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return .placeholder }

        return WidgetData(
            quote: json["quote"] as? String ?? placeholder.quote,
            author: json["author"] as? String ?? placeholder.author,
            imagePath: json["imagePath"] as? String
        )
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: .now, data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(QuoteEntry(date: .now, data: .load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let data = WidgetData.load()
        let entry = QuoteEntry(date: .now, data: data)
        let defaults = UserDefaults(suiteName: "group.com.inovacetech.quotewidget")
        let interval = defaults?.integer(forKey: "refresh_interval_minutes") ?? 30
        let next = Calendar.current.date(byAdding: .minute, value: interval, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct QuoteWidgetView: View {
    var entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background image
                if let path = entry.data.imagePath,
                   let uiImage = UIImage(contentsOfFile: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.black
                }

                // Gradient scrim
                LinearGradient(
                    colors: [.clear, .black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                // Quote text
                VStack(alignment: .leading, spacing: 4) {
                    Text("\u{201C}\(entry.data.quote)\u{201D}")
                        .font(family == .systemSmall ? .caption : .footnote)
                        .italic()
                        .foregroundColor(.white)
                        .lineLimit(family == .systemSmall ? 3 : 5)
                    Text("— \(entry.data.author)")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(10)
            }
        }
    }
}

@main
struct QuoteWidgetBundle: Widget {
    let kind = "QuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            QuoteWidgetView(entry: entry)
        }
        .configurationDisplayName("Quote Widget")
        .description("Random image with an inspiring quote.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
```

- [ ] **Step 5: Remove the generated QuoteWidgetBundle.swift if it exists**

```bash
rm -f ios/QuoteWidget/QuoteWidgetBundle.swift
```

(The `@main` entry point is in `QuoteWidget.swift` above.)

- [ ] **Step 6: Build for iOS**

```bash
flutter build ios --debug --no-codesign
```

Expected: build succeeds, widget extension included.

- [ ] **Step 7: Test on device**

1. Run on a physical iOS device (Simulator does not support WidgetKit)
2. Long-press home screen → + → search "Quote Widget" → add
3. Widget shows placeholder quote on first add
4. Open app (triggers refresh + `WidgetCenter.reloadAllTimelines()`) → return to home → widget shows image + quote
5. Change refresh interval in Settings → verify timeline reloads

- [ ] **Step 8: Commit**

```bash
git add ios/
git commit -m "feat: add iOS WidgetKit extension"
```

---

## Self-Review

**Spec coverage check:**
- ✅ KaiOS migration → Task 1
- ✅ Flutter project setup → Task 1
- ✅ Bundled anime images (33) → Task 2
- ✅ Bundled fallback quotes (50) → Task 2
- ✅ Data models → Task 3
- ✅ Quote cache (sqflite) → Task 4
- ✅ QuoteService: animechan + zenquotes + bundled fallback → Task 5
- ✅ ImageService: bundled + user photos, shared dir → Task 6
- ✅ WidgetDataRepository → Task 7
- ✅ RefreshScheduler (workmanager) → Task 8
- ✅ MainScreen: full-screen image + quote, tap to refresh → Task 9
- ✅ SettingsScreen: interval, style, images → Task 10
- ✅ main.dart wiring + first-launch init → Task 11
- ✅ Android AppWidget → Task 12
- ✅ iOS WidgetKit → Task 13
- ✅ First widget render never blank → Tasks 12 + 13 (placeholder fallback)
- ✅ First launch empty cache fallback → Task 5 (bundled fallback in getRandomQuote)
- ✅ Widget refresh interval configurable in app → Tasks 8 + 10 + 13
- ✅ Widget tap deep-links to app → Tasks 12 + 13
