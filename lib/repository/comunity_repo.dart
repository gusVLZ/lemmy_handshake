import 'package:lemmy_account_sync/model/community.dart';
import 'package:sqflite/sqflite.dart';

class CommunityRepo {
  final Database dbConnection;
  CommunityRepo({required this.dbConnection});

  Future<int> insert(Community community) async {
    return await dbConnection.insert('communities', community.toMap());
  }

  Future<List<Community>> getAll() async {
    final List<Map<String, dynamic>> maps =
        await dbConnection.query('communities', where: "removedAt is null");
    return List.generate(maps.length, (i) {
      return Community.fromDb(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getLastState30Days(DateTime after) async {
    final List<Map<String, dynamic>> maps = await dbConnection.rawQuery("""
      select 
        community, 
        max(ifnull(removedAt, createdAt)) as 'lastUpdate', 
        case when max(removedAt)>max(createdAt) then 'unsubscribed' else 'subscribed' end as 'state'
      from communities
      where ifnull(removedAt, createdAt) > '$after'
      group by community
    """);

    return maps;
  }

  Future<List<Community>> getAllFromAccount(int accountId) async {
    final List<Map<String, dynamic>> maps = await dbConnection
        .query('communities', where: "accountId = ?", whereArgs: [accountId]);
    return List.generate(maps.length, (i) {
      return Community.fromDb(maps[i]);
    });
  }

  Future<int> update(Community community) async {
    return await dbConnection.update('communities', community.toMap(),
        where: 'externalId = ?', whereArgs: [community.externalId]);
  }

  Future<int> delete(String id) async {
    return await dbConnection
        .delete('communityId', where: 'externalId = ?', whereArgs: [id]);
  }

  Future<int> softDelete(String externalId) async {
    return await dbConnection.rawUpdate(
        'UPDATE communities SET removedAt = ? where externalId = ?',
        [DateTime.now().toIso8601String(), externalId]);
  }
}
