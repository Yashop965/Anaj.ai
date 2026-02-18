import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'digital_doctor.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diagnosis(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        diseaseName TEXT,
        confidence REAL,
        timestamp TEXT,
        isSynced INTEGER, 
        actionPlan TEXT,
        audioUrl TEXT
      )
    ''');
  }

  Future<int> insertDiagnosis(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('diagnosis', row);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    Database db = await database;
    return await db.query('diagnosis', where: 'isSynced = ?', whereArgs: [0]);
  }

  Future<void> updateSyncStatus(int id, int status) async {
    Database db = await database;
    await db.update('diagnosis', {'isSynced': status}, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<List<Map<String, dynamic>>> getAllDiagnoses() async {
    Database db = await database;
    return await db.query('diagnosis', orderBy: 'timestamp DESC');
  }
}
