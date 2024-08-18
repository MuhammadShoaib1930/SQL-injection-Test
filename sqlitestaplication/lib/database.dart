import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = "my_database.db";
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertUser(String email, String password) async {
    final db = await database;
    await db.rawInsert(
      'INSERT INTO users (email, password) VALUES (?, ?)',
      [email, password],
    );
  }

  Future<List<Map<String, dynamic>>> fetchUsers({String? email}) async {
    final db = await database;
    if (email != null && email.isNotEmpty) {
      // Use parameterized query to prevent SQL Injection
      return await db.rawQuery(
        'SELECT * FROM users WHERE email = ?',
        [email],
      );
    } else {
      // Fetch all users if no email is provided
      return await db.rawQuery('SELECT * FROM users');
    }
  }
}
