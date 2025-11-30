import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/language.dart';

class LanguageRepository {
  static const String tableName = 'languages';

  Future<int> create(Language language) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, language.toMap());
  }

  Future<List<Language>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(
      tableName,
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'sortOrder ASC, name ASC',
    );
    return result.map(Language.fromMap).toList();
  }

  Future<List<Language>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'sortOrder ASC, name ASC');
    return result.map(Language.fromMap).toList();
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
