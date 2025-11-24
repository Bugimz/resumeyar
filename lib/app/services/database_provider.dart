import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  DatabaseProvider._internal();

  static final DatabaseProvider instance = DatabaseProvider._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'resume_database.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE resume_profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            summary TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE work_experiences (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            company TEXT NOT NULL,
            position TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            description TEXT NOT NULL,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE educations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            school TEXT NOT NULL,
            degree TEXT NOT NULL,
            fieldOfStudy TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT NOT NULL,
            description TEXT NOT NULL,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE skills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            name TEXT NOT NULL,
            level TEXT NOT NULL,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            link TEXT NOT NULL,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }
}
