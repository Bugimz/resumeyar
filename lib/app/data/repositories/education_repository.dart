import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/education.dart';

class EducationRepository {
  static const String tableName = 'educations';

  Future<int> create(Education education) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, education.toMap());
  }

  Future<Education?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return Education.fromMap(result.first);
  }

  Future<List<Education>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'profileId = ?', whereArgs: [profileId]);
    return result.map((map) => Education.fromMap(map)).toList();
  }

  Future<int> update(Education education) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      education.toMap(),
      where: 'id = ?',
      whereArgs: [education.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
