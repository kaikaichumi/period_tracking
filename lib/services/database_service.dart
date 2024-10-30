// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/period_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('period_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startDate TEXT NOT NULL,
        endDate TEXT,
        flowIntensity TEXT NOT NULL,
        painLevel INTEGER NOT NULL,
        symptoms TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cycleLength INTEGER NOT NULL,
        periodLength INTEGER NOT NULL,
        notificationsEnabled INTEGER NOT NULL,
        reminderTime TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertPeriod(PeriodRecord record) async {
    final db = await database;
    return await db.insert(
      'periods',
      record.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PeriodRecord>> getAllPeriods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('periods');
    return List.generate(maps.length, (i) => PeriodRecord.fromJson(maps[i]));
  }

  Future<void> updatePeriod(PeriodRecord record) async {
    final db = await database;
    await db.update(
      'periods',
      record.toJson(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deletePeriod(int id) async {
    final db = await database;
    await db.delete(
      'periods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}