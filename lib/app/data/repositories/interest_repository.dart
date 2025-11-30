import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/interest.dart';

class InterestRepository {
  static const String tableName = 'interests';

  Future<int> create(Interest interest) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, interest.toMap());
  }

  Future<Interest?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Interest.fromMap(result.first);
  }

  Future<List<Interest>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'id DESC');
    return result.map((map) => Interest.fromMap(map)).toList();
  }

  Future<int> update(Interest interest) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      interest.toMap(),
      where: 'id = ?',
      whereArgs: [interest.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
