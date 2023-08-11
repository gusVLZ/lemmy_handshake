import 'package:lemmy_account_sync/dto/sync_response.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/model/community.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/repository/comunity_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/lemmy.dart';
import 'package:sqflite/sqflite.dart';

class SyncMotor {
  late Database _dbConnection;
  SyncMotor(Database db) {
    _dbConnection = db;
  }

  static Future<SyncMotor> createAsync() async {
    final data =
        await Db().getDatabase(); // Assuming fetchData is an async method
    return SyncMotor(data);
  }

  Future<void> syncAccounts() async {
    List<Account> accounts =
        await AccountRepo(dbConnection: _dbConnection).getAll();

    for (var acc in accounts) {
      syncSubscriptionForAccount(acc);
    }
  }

  Future<SyncResponse> syncSubscriptionForAccount(Account acc) async {
    Lemmy lemmyClient = Lemmy(acc.instance);
    CommunityRepo communityRepo = CommunityRepo(dbConnection: _dbConnection);

    var onlineCommunities = await lemmyClient.getCommunities();

    var localCommunities = await communityRepo
        .getAllFromAccount(acc.instance)
        .then((value) => value.map((e) => e.community));

    var toAdd = onlineCommunities.where((c) => !localCommunities.contains(c));
    var toDelete =
        localCommunities.where((c) => !onlineCommunities.contains(c));

    for (var community in toAdd) {
      communityRepo.insert(Community(
          communityId: community,
          accountId: acc.accountId,
          community: community,
          createdAt: DateTime.now()));
    }

    for (var community in toDelete) {
      communityRepo.update(Community(
          communityId: community,
          accountId: acc.accountId,
          community: community,
          removedAt: DateTime.now()));
    }

    return SyncResponse(
        accountId: acc.instance,
        added: toAdd.toList(),
        removed: toDelete.toList(),
        when: DateTime.now());
  }
}
