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
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE resume_profiles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT NOT NULL,
            jobTitle TEXT NOT NULL DEFAULT '',
            location TEXT NOT NULL DEFAULT '',
            email TEXT NOT NULL,
            phone TEXT NOT NULL,
            summary TEXT NOT NULL,
            portfolioUrl TEXT NOT NULL DEFAULT '',
            linkedInUrl TEXT NOT NULL DEFAULT '',
            githubUrl TEXT NOT NULL DEFAULT '',
            imagePath TEXT,
            signaturePath TEXT
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
            achievements TEXT NOT NULL DEFAULT '[]',
            techTags TEXT NOT NULL DEFAULT '[]',
            metric TEXT,
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
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE resume_profiles ADD COLUMN imagePath TEXT');
          await db.execute('ALTER TABLE resume_profiles ADD COLUMN signaturePath TEXT');
        }

        if (oldVersion < 3) {
          await db.execute(
              "ALTER TABLE resume_profiles ADD COLUMN jobTitle TEXT NOT NULL DEFAULT ''");
          await db.execute(
              "ALTER TABLE resume_profiles ADD COLUMN location TEXT NOT NULL DEFAULT ''");
          await db.execute(
              "ALTER TABLE resume_profiles ADD COLUMN portfolioUrl TEXT NOT NULL DEFAULT ''");
          await db.execute(
              "ALTER TABLE resume_profiles ADD COLUMN linkedInUrl TEXT NOT NULL DEFAULT ''");
          await db.execute(
              "ALTER TABLE resume_profiles ADD COLUMN githubUrl TEXT NOT NULL DEFAULT ''");
        }

        if (oldVersion < 4) {
          await db.execute(
              "ALTER TABLE work_experiences ADD COLUMN achievements TEXT NOT NULL DEFAULT '[]'");
          await db.execute(
              "ALTER TABLE work_experiences ADD COLUMN techTags TEXT NOT NULL DEFAULT '[]'");
          await db.execute(
              'ALTER TABLE work_experiences ADD COLUMN metric TEXT');
        }
      },
    );
  }
}
