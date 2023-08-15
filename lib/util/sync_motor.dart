import 'dart:convert';

import 'package:lemmy_account_sync/dto/sync_response.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/model/community.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/repository/comunity_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/lemmy.dart';
import 'package:lemmy_account_sync/util/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncMotor {
  late Database _dbConnection;
  final storage = const FlutterSecureStorage();

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
      await syncSubscriptionForAccount(acc);
    }
  }

  Future<SyncResponse> syncSubscriptionForAccount(Account acc) async {
    Lemmy lemmyClient = Lemmy(acc.instance);

    String? password =
        await storage.read(key: '${acc.username}@${acc.instance}');
    if (password == null || password.isEmpty) {
      Logger.error(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
      throw Exception(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
    }

    await lemmyClient.login(acc.username, password);
    CommunityRepo communityRepo = CommunityRepo(dbConnection: _dbConnection);

    var onlineCommunities = await lemmyClient.getCommunities();

    var localCommunities = await communityRepo
        .getAll()
        .then((value) => value.map((e) => e.externalId));

    var toAdd = onlineCommunities
        .where((c) => !localCommunities.contains("$c@${acc.instance}"));
    var toDelete = localCommunities
        .where((c) => !onlineCommunities.contains(c.split("@")[0]));

    for (var community in toAdd) {
      await communityRepo.insert(
        Community(
            externalId: "$community@${acc.instance}",
            accountId: acc.id,
            community: community,
            createdAt: DateTime.now(),
            removedAt: null),
      );
    }

    for (var community in toDelete) {
      await communityRepo.softDelete(community);
    }

    AccountRepo(dbConnection: _dbConnection).updateLastSync(acc.id!);

    var response = SyncResponse(
      accountId: acc.instance,
      added: toAdd.toList(),
      removed: toDelete.toList(),
      when: DateTime.now(),
    );

    Logger.info("SYNC RESULT: ${jsonEncode(response.toMap())}");

    return response;
  }
}
