import 'package:lemmy_account_sync/model/community.dart';
import 'package:sqflite/sqflite.dart';

class CommunityRepo {
  final Database dbConnection;
  CommunityRepo({required this.dbConnection});

  Future<int> insert(Community community) async {
    return await dbConnection.insert('communities', community.toJson());
  }

  Future<List<Community>> getAll() async {
    final List<Map<String, dynamic>> maps =
        await dbConnection.query('communities');
    return List.generate(maps.length, (i) {
      return Community(
        communityId: maps[i]['communityId'],
        accountId: maps[i]['accountId'],
        community: maps[i]['community'],
        createdAt: maps[i]['createdAt'],
        removedAt: maps[i]['removedAt'],
      );
    });
  }

  Future<List<Community>> getAllFromAccount(String accountId) async {
    final List<Map<String, dynamic>> maps = await dbConnection
        .query('communities', where: "accountId = ?", whereArgs: [accountId]);
    return List.generate(maps.length, (i) {
      return Community(
        communityId: maps[i]['communityId'],
        accountId: maps[i]['accountId'],
        community: maps[i]['community'],
        createdAt: maps[i]['createdAt'],
        removedAt: maps[i]['removedAt'],
      );
    });
  }

  Future<int> update(Community community) async {
    return await dbConnection.update('communities', community.toJson(),
        where: 'communityId = ?', whereArgs: [community.communityId]);
  }

  Future<int> delete(String id) async {
    return await dbConnection
        .delete('communityId', where: 'accountId = ?', whereArgs: [id]);
  }
}
