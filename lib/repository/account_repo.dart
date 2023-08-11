import 'package:lemmy_account_sync/model/account.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepo {
  final Database dbConnection;
  AccountRepo({required this.dbConnection});

  Future<int> insert(Account account) async {
    return await dbConnection.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAll() async {
    final List<Map<String, dynamic>> maps =
        await dbConnection.query('accounts');
    return List.generate(maps.length, (i) {
      return Account(
        accountId: maps[i]['accountId'],
        username: maps[i]['username'],
        password: maps[i]['password'],
        instance: maps[i]['instance'],
        lastSync: maps[i]['lastSync'],
        nuSubscription: maps[i]['nuSubscription'],
        nuPost: maps[i]['nuPost'],
        nuComment: maps[i]['nuComment'],
        profileUrl: maps[i]['profileUrl'],
      );
    });
  }

  Future<int> update(Account account) async {
    return await dbConnection.update('accounts', account.toMap(),
        where: 'accountId = ?', whereArgs: [account.accountId]);
  }

  Future<int> delete(String accountId) async {
    return await dbConnection
        .delete('accounts', where: 'accountId = ?', whereArgs: [accountId]);
  }
}
