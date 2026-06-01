import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/routine.dart';
import '../models/user_profile.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'routine_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE routines ADD COLUMN scheduledDays TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        gender TEXT NOT NULL,
        password TEXT NOT NULL,
        avatarKey TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE routines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL,
        streak INTEGER NOT NULL DEFAULT 0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedTime TEXT,
        scheduledDays TEXT
      )
    ''');
  }

  // --- User Profile Operations ---

  Future<void> saveProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'user_profile',
      {
        'id': 1, // Single user profile record
        'username': profile.username,
        'email': profile.email,
        'gender': profile.gender,
        'password': profile.password,
        'avatarKey': profile.avatarKey,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _printDatabaseState();
  }

  Future<UserProfile?> getProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
    );

    if (maps.isEmpty) return null;

    return UserProfile(
      username: maps.first['username'] as String,
      email: maps.first['email'] as String,
      gender: maps.first['gender'] as String,
      password: maps.first['password'] as String,
      avatarKey: maps.first['avatarKey'] as String,
    );
  }

  Future<void> deleteProfile() async {
    final db = await database;
    await db.delete('user_profile', where: 'id = ?', whereArgs: [1]);
  }

  // --- Routine Operations ---

  Future<void> saveRoutines(List<Routine> routines) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('routines');
      for (final routine in routines) {
        await txn.insert(
          'routines',
          {
            if (routine.id != null) 'id': routine.id,
            'title': routine.title,
            'time': routine.time,
            'category': routine.category,
            'frequency': routine.frequency,
            'streak': routine.streak,
            'isCompleted': routine.isCompleted ? 1 : 0,
            'completedTime': routine.completedTime,
            'scheduledDays': routine.scheduledDays.join(','),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    await _printDatabaseState();
  }

  Future<List<Routine>> getRoutines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('routines');

    return List.generate(maps.length, (i) {
      List<int> parseScheduledDays(dynamic value) {
        if (value == null) return [1, 2, 3, 4, 5, 6, 7];
        final str = value.toString();
        if (str.isEmpty) return [1, 2, 3, 4, 5, 6, 7];
        try {
          return str.split(',').map((e) => int.parse(e.trim())).toList();
        } catch (_) {
          return [1, 2, 3, 4, 5, 6, 7];
        }
      }

      return Routine(
        id: maps[i]['id'] as int?,
        title: maps[i]['title'] as String,
        time: maps[i]['time'] as String,
        category: maps[i]['category'] as String,
        frequency: maps[i]['frequency'] as String,
        streak: maps[i]['streak'] as int,
        isCompleted: maps[i]['isCompleted'] == 1,
        completedTime: maps[i]['completedTime'] as String?,
        scheduledDays: parseScheduledDays(maps[i]['scheduledDays']),
      );
    });
  }

  Future<void> clearRoutines() async {
    final db = await database;
    await db.delete('routines');
  }

  // --- Debug helper to log the SQLite data ---
  Future<void> _printDatabaseState() async {
    try {
      final db = await database;
      final profiles = await db.query('user_profile');
      final routines = await db.query('routines');
      print('=== SQLite Database State ===');
      print('User Profiles: $profiles');
      print('Routines (${routines.length} routines stored):');
      for (var row in routines) {
        print('  - ID: ${row['id']}, Title: ${row['title']}, Completed: ${row['isCompleted']}, Streak: ${row['streak']}');
      }
      print('=============================');
    } catch (e) {
      print('Error printing database state: $e');
    }
  }
}
