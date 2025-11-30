import 'package:sqflite/sqflite.dart';

import '../../services/database_provider.dart';
import '../models/certification.dart';

class CertificationRepository {
  static const String tableName = 'certifications';

  Future<int> create(Certification certification) async {
    final db = await DatabaseProvider.instance.database;
    return db.insert(tableName, certification.toMap());
  }

  Future<List<Certification>> getByProfile(int profileId) async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(
      tableName,
      where: 'profileId = ?',
      whereArgs: [profileId],
      orderBy: 'sortOrder ASC, issueDate DESC',
    );
    return result.map(Certification.fromMap).toList();
  }

  Future<List<Certification>> getAll() async {
    final db = await DatabaseProvider.instance.database;
    final result = await db.query(tableName, orderBy: 'sortOrder ASC, issueDate DESC');
    return result.map(Certification.fromMap).toList();
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
