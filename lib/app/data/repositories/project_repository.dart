import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/project.dart';

class ProjectRepository {
  static const String tableName = 'projects';

  Future<int> create(Project project) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, project.toMap());
  }

  Future<Project?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) {
      return null;
    }
    return Project.fromMap(result.first);
  }

  Future<List<Project>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(
      tableName,
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'isFeatured DESC, id DESC',
    );
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<List<Project>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'isFeatured DESC, id DESC');
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<int> update(Project project) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      project.toMap(),
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
