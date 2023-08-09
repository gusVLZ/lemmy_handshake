import 'package:lemmy_account_sync/model/account_details.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Db {
  late Database _database;

  Future<void> startDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accountSync.db');

    _database = await openDatabase(path,
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

  Future<int> insertUser(AccountDetails account) async {
    return await _database.insert('users', account.toMap());
  }

  Future<List<AccountDetails>> getUsers() async {
    final List<Map<String, dynamic>> maps = await _database.query('users');
    return List.generate(maps.length, (i) {
      return AccountDetails(
        accountId: maps[i]['accountId'],
        username: maps[i]['username'],
        instance: maps[i]['instance'],
        lastSync: maps[i]['lastSync'],
        profileUrl: maps[i]['profileUrl'],
      );
    });
  }

  Future<int> updateUser(AccountDetails user) async {
    return await _database.update('users', user.toMap(),
        where: 'accountId = ?', whereArgs: [user.accountId]);
  }

  Future<int> deleteUser(String accountId) async {
    return await _database
        .delete('users', where: 'accountId = ?', whereArgs: [accountId]);
  }
}
