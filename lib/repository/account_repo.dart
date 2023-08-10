import 'package:lemmy_account_sync/model/account.dart';
import 'package:sqflite/sqflite.dart';

class AccountRepo {
  final Database dbConnection;
  AccountRepo({required this.dbConnection});
  Future<int> insertAccount(Account account) async {
    return await dbConnection.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAccounts() async {
    final List<Map<String, dynamic>> maps =
        await dbConnection.query('accounts');
    return List.generate(maps.length, (i) {
      return Account(
        accountId: maps[i]['accountId'],
        username: maps[i]['username'],
        instance: maps[i]['instance'],
        lastSync: maps[i]['lastSync'],
        profileUrl: maps[i]['profileUrl'],
      );
    });
  }

  Future<int> updateAccount(Account account) async {
    return await dbConnection.update('accounts', account.toMap(),
        where: 'accountId = ?', whereArgs: [account.accountId]);
  }

  Future<int> deleteAccount(String accountId) async {
    return await dbConnection
        .delete('accounts', where: 'accountId = ?', whereArgs: [accountId]);
  }
}
