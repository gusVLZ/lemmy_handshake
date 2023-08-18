import 'dart:convert';

import 'package:lemmy_handshake/model/account.dart';
import 'package:lemmy_handshake/util/logger.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepo {
  final Database dbConnection;
  AccountRepo({required this.dbConnection});

  Future<int> insert(Account account) async {
    return await dbConnection.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAll() async {
    final List<Map<String, dynamic>> maps =
        //await dbConnection.query('accounts');
        await dbConnection.rawQuery(
            """select a.*, count(c.id) as 'nuSubscription' from accounts a 
            left join communities c on a.id = c.accountId and c.removedAt is null
            group by a.id, a.externalId, a.username, a.instance, a.lastSync, a.profileUrl, a.nuSubscription, a.nuPost, a.nuComment
            """);
    Logger.debug("database query: ${jsonEncode(maps)}");
    return List.generate(maps.length, (i) {
      return Account.fromDb(maps[i]);
    });
  }

  Future<int> update(Account account) async {
    return await dbConnection.update('accounts', account.toMap(),
        where: 'externalId = ?', whereArgs: [account.externalId]);
  }

  Future<int> updateLastSync(int id) async {
    return await dbConnection.rawUpdate(
        'UPDATE accounts SET lastSync = ? where id = ?',
        [DateTime.now().toIso8601String(), id]);
  }

  Future<int> delete(int accountId) async {
    await dbConnection
        .delete('communities', where: 'accountId = ?', whereArgs: [accountId]);
    return await dbConnection
        .delete('accounts', where: 'id = ?', whereArgs: [accountId]);
  }
}
