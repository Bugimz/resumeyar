import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../data/models/skill.dart';

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
      version: 3,
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
            gpa REAL,
            showGpa INTEGER NOT NULL DEFAULT 0,
            honors TEXT NOT NULL DEFAULT '[]',
            courses TEXT NOT NULL DEFAULT '[]',
            sortOrder INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE skills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            name TEXT NOT NULL,
            level TEXT NOT NULL,
            category TEXT NOT NULL DEFAULT 'General',
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
            role TEXT NOT NULL DEFAULT '',
            responsibilities TEXT NOT NULL DEFAULT '[]',
            techTags TEXT NOT NULL DEFAULT '[]',
            demoLink TEXT NOT NULL DEFAULT '',
            githubLink TEXT NOT NULL DEFAULT '',
            liveLink TEXT NOT NULL DEFAULT '',
            thumbnailUrl TEXT NOT NULL DEFAULT '',
            isFeatured INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE certifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            name TEXT NOT NULL,
            issuer TEXT NOT NULL,
            issueDate TEXT NOT NULL,
            credentialUrl TEXT NOT NULL DEFAULT '',
            sortOrder INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE languages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            name TEXT NOT NULL,
            level TEXT NOT NULL,
            sortOrder INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(profileId) REFERENCES resume_profiles(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE interests (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            profileId INTEGER NOT NULL,
            title TEXT NOT NULL,
            details TEXT NOT NULL DEFAULT '',
            sortOrder INTEGER NOT NULL DEFAULT 0,
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
            "ALTER TABLE skills ADD COLUMN category TEXT NOT NULL DEFAULT 'General'",
          );
        }
      },
    );
  }
}
