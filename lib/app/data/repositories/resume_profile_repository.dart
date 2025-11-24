import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/resume_profile.dart';

class ResumeProfileRepository {
  static const String tableName = 'resume_profiles';

  Future<int> create(ResumeProfile profile) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, profile.toMap());
  }

  Future<ResumeProfile?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return ResumeProfile.fromMap(result.first);
  }

  Future<List<ResumeProfile>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName);
    return result.map((map) => ResumeProfile.fromMap(map)).toList();
  }

  Future<int> update(ResumeProfile profile) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
