import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/skill.dart';

class SkillRepository {
  static const String tableName = 'skills';

  Future<int> create(Skill skill) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, skill.toMap());
  }

  Future<Skill?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return Skill.fromMap(result.first);
  }

  Future<List<Skill>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(
      tableName,
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'sortOrder ASC, id ASC',
    );
    return result.map((map) => Skill.fromMap(map)).toList();
  }

  Future<List<Skill>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'category ASC, sortOrder ASC');
    return result.map((map) => Skill.fromMap(map)).toList();
  }

  Future<int> update(Skill skill) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      skill.toMap(),
      where: 'id = ?',
      whereArgs: [skill.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateMany(List<Skill> skills) async {
    final db = await DatabaseProvider.instance.database;
    final batch = db.batch();
    for (final skill in skills) {
      batch.update(
        tableName,
        skill.toMap(),
        where: 'id = ?',
        whereArgs: [skill.id],
      );
    }
    await batch.commit(noResult: true);
  }
}
