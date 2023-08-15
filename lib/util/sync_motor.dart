import 'dart:convert';

import 'package:lemmy_account_sync/dto/sync_account.dart';
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
  final List<SyncAccount> _syncAccountDTO = [];

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
      await syncOnlineToLocal(acc);
    }

    for (var acc in accounts) {
      var lemmy = Lemmy(acc.instance);
      await lemmy.login(acc.username, acc.password!);

      var localUpdates = await CommunityRepo(dbConnection: _dbConnection)
          .getLastState30Days(acc.lastSync ?? DateTime(2020));

      var toAdd = localUpdates
          .where((element) => element['state'] == 'subscribed')
          .map((e) => e['community'].toString())
          .toList();
      var toRemove = localUpdates
          .where((element) => element['state'] == 'unsubscribed')
          .map((e) => e['community'].toString())
          .toList();

      await lemmy.subscribe(toAdd);
      await lemmy.subscribe(toRemove, follow: false);

      AccountRepo(dbConnection: _dbConnection).updateLastSync(acc.id!);
    }

    for (var acc in accounts) {
      await syncOnlineToLocal(acc);
    }
  }

  Future<SyncResponse> syncOnlineToLocal(Account acc) async {
    Lemmy lemmyClient = Lemmy(acc.instance);

    String? password =
        await storage.read(key: '${acc.username}@${acc.instance}');
    if (password == null || password.isEmpty) {
      Logger.error(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
      throw Exception(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
    }

    acc.password = password;

    await lemmyClient.login(acc.username, acc.password!);
    CommunityRepo communityRepo = CommunityRepo(dbConnection: _dbConnection);

    var onlineCommunities = await lemmyClient.getCommunities();

    var localCommunities = await communityRepo
        .getAllFromAccount(acc.id!)
        .then((value) => value.map((e) => e.externalId));

    var toAdd = onlineCommunities
        .where((c) => !localCommunities.contains("$c@${acc.instance}"));
    var toDelete = localCommunities
        .where((c) => !onlineCommunities.contains(c.split("@")[0]));

    var response = SyncResponse(
      accountId: acc.instance,
      added: [],
      removed: [],
      failedToAdd: [],
      failedToRemove: [],
      when: DateTime.now(),
    );

    for (var community in toAdd) {
      try {
        await communityRepo.insert(
          Community(
              externalId: "$community@${acc.instance}",
              accountId: acc.id,
              community: community,
              createdAt: DateTime.now(),
              removedAt: null),
        );
        response.added.add(community);
      } catch (e) {
        response.failedToAdd.add(community);
      }
    }

    for (var community in toDelete) {
      try {
        await communityRepo.softDelete(community);
        response.removed.add(community);
      } catch (e) {
        response.failedToRemove.add(community);
      }
    }

    Logger.info("SYNC TO LOCAL: ${jsonEncode(response.toMap())}");

    _syncAccountDTO.add(SyncAccount(
        account: acc, toAdd: toAdd.toSet(), toDelete: toAdd.toSet()));

    return response;
  }
}
