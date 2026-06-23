import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  static Future<Database> initDatabase() async {
    String path = join(
      await getDatabasesPath(),
      'glass_track.db',
    );

    return await openDatabase(
      path,
      version: 1,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE collections(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            supplierCode TEXT,
            clearKg REAL,
            coloredKg REAL,
            condition TEXT
          )
        ''');
      },
    );
  }

  static Future<void> saveCollection({
    required String supplierCode,
    required double clearKg,
    required double coloredKg,
    required String condition,
  }) async {
    final db = await database;

    await db.insert(
      'collections',
      {
        'supplierCode': supplierCode,
        'clearKg': clearKg,
        'coloredKg': coloredKg,
        'condition': condition,
      },
    );
  }

  static Future<List<Map<String, dynamic>>>
      getCollections() async {
    final db = await database;

    return await db.query('collections');
  }
}