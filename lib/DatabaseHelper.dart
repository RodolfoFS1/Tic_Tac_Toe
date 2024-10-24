import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tictactoe.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE games(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            board TEXT,
            winsX INTEGER,
            winsO INTEGER,
            draws INTEGER,
            isXTurn INTEGER
          )
        ''');
      },
    );
  }

  Future<void> insertGame(Map<String, dynamic> gameData) async {
    final db = await database;
    await db.insert(
      'games',
      gameData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getGames() async {
    final db = await database;
    return await db.query('games');
  }

  Future<void> deleteGame(int id) async {
    final db = await database;
    await db.delete(
      'games',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearGames() async {
    final db = await database;
    await db.delete('games');
  }
}
