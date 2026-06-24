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
