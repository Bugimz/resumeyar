import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/certification.dart';

class CertificationRepository {
  static const String tableName = 'certifications';

  Future<int> create(Certification certification) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, certification.toMap());
  }

  Future<Certification?> getById(int id) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Certification.fromMap(result.first);
  }

  Future<List<Certification>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'id DESC');
    return result.map((map) => Certification.fromMap(map)).toList();
  }

  Future<int> update(Certification certification) async {
    final db = await DatabaseProvider.instance.database;
    return db.update(
      tableName,
      certification.toMap(),
      where: 'id = ?',
      whereArgs: [certification.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await DatabaseProvider.instance.database;
    return db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
