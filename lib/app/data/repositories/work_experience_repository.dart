import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/work_experience.dart';

class WorkExperienceRepository {
  static const String tableName = 'work_experiences';

  Future<int> create(WorkExperience experience) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, experience.toMap());
  }

  Future<WorkExperience?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return WorkExperience.fromMap(result.first);
  }

  Future<List<WorkExperience>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'profileId = ?', whereArgs: [profileId]);
    return result.map((map) => WorkExperience.fromMap(map)).toList();
  }

  Future<int> update(WorkExperience experience) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      experience.toMap(),
      where: 'id = ?',
      whereArgs: [experience.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
