import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/language.dart';

class LanguageRepository {
  static const String tableName = 'languages';

  Future<int> create(Language language) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, language.toMap());
  }

  Future<Language?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Language.fromMap(result.first);
  }

  Future<List<Language>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'id DESC');
    return result.map((map) => Language.fromMap(map)).toList();
  }

  Future<int> update(Language language) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      language.toMap(),
      where: 'id = ?',
      whereArgs: [language.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
