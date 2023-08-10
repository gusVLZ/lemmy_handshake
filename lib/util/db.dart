import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Db {
  Future<Database> startDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accountSync.db');

    return await openDatabase(path,
        version: 1, // This should be the version of the database schema
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts(
          accountId TEXT PRIMARY KEY,
          username TEXT,
          instance TEXT,
          lastSync TEXT,
          profileUrl TEXT
        )
      ''');
    });
  }

  Future<Database> getDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accountSync.db');

    return await openDatabase(
      path,
      version: 1, // This should be the version of the database schema
    );
  }
}
