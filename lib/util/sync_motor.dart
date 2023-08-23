import 'dart:convert';

import 'package:lemmy_handshake/dto/sync_account.dart';
import 'package:lemmy_handshake/dto/sync_response.dart';
import 'package:lemmy_handshake/model/account.dart';
import 'package:lemmy_handshake/model/community.dart';
import 'package:lemmy_handshake/repository/account_repo.dart';
import 'package:lemmy_handshake/repository/comunity_repo.dart';
import 'package:lemmy_handshake/util/credential_utils.dart';
import 'package:lemmy_handshake/util/db.dart';
import 'package:lemmy_handshake/util/lemmy.dart';
import 'package:lemmy_handshake/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SyncMotor {
  late Database _dbConnection;
  final storage = const FlutterSecureStorage();
  final List<SyncAccount> _syncAccountDTO = [];
  Function(String)? statusUpdateHandler;

  SyncMotor(Database db, {this.statusUpdateHandler}) {
    _dbConnection = db;
  }

  static Future<SyncMotor> createAsync(
      {Function(String)? statusUpdateHandler}) async {
    final data = await Db().getDatabase();
    return SyncMotor(data, statusUpdateHandler: statusUpdateHandler);
  }

  void callLogHandler(String message) {
    if (statusUpdateHandler != null) {
      statusUpdateHandler!(message);
    } else {
      Logger.info(message);
    }
  }

  Future<SyncResponse> syncAccounts() async {
    var shared = await SharedPreferences.getInstance();
    var isUnfollowAllowed = shared.getBool("is_unfollow_allowed") != null &&
        shared.getBool("is_unfollow_allowed")!;

    List<Account> accounts =
        await AccountRepo(dbConnection: _dbConnection).getAll();

    var finalResult = SyncResponse(
        accountId: "0",
        added: [],
        failedToAdd: [],
        failedToRemove: [],
        removed: [],
        when: DateTime.now());

    for (var acc in accounts) {
      try {
        await syncOnlineToLocal(acc);
      } catch (e) {
        callLogHandler(e.toString());
        continue;
      }
    }

    for (var acc in accounts) {
      var lemmy = Lemmy(acc.instance);
      var loginResult = await lemmy.login(acc.username, acc.password!);
      if (!loginResult) {
        callLogHandler(
            "Login failed for account ${acc.username}@${acc.instance}");
        continue;
      }

      var localUpdates = await CommunityRepo(dbConnection: _dbConnection)
          .getLastState30Days(acc.lastSync ?? DateTime(2020), acc.id!);

      var accountLocalState = await CommunityRepo(dbConnection: _dbConnection)
          .getAllFromAccount(acc.id!, acc.lastSync ?? DateTime.now());

      localUpdates = localUpdates
          .where((c) => !accountLocalState
              .map((e) =>
                  e.community +
                  (e.removedAt == null ? "subscribed" : "unsubscribed"))
              .contains(c['community'] + c['state']))
          .toList();

      var toAdd = localUpdates
          .where((element) => element['state'] == 'subscribed')
          .map((e) => e['community'].toString())
          .toList();
      var toRemove = localUpdates
          .where((element) => element['state'] == 'unsubscribed')
          .map((e) => e['community'].toString())
          .toList();

      if ((toAdd.isNotEmpty || toRemove.isNotEmpty) && isUnfollowAllowed) {
        callLogHandler(
            "${acc.username}@${acc.instance} - Sync will subscribe to ${toAdd.length} communities, and unsubscribe from ${toRemove.length} communities");
      }

      var progress = 0;
      for (var url in toAdd) {
        progress++;
        callLogHandler("Following $url - ($progress/${toAdd.length})");
        if (await lemmy.subscribe(url)) {
          finalResult.added.add(url);
        } else {
          finalResult.failedToAdd.add(url);
          callLogHandler("Couldn't subscribe");
        }
      }
      progress = 0;
      if (isUnfollowAllowed) {
        for (var url in toRemove) {
          progress++;
          callLogHandler("Unfollowing $url - ($progress/${toRemove.length})");
          if (await lemmy.subscribe(url, follow: false)) {
            finalResult.removed.add(url);
          } else {
            finalResult.failedToRemove.add(url);
            callLogHandler("Couldn't unsubscribe");
          }
        }
      }
    }

    callLogHandler("Saving sync changes");
    for (var acc in accounts) {
      try {
        await syncOnlineToLocal(acc);
      } catch (e) {
        continue;
      }
      await AccountRepo(dbConnection: _dbConnection).updateLastSync(acc.id!);
    }

    return finalResult;
  }

  Future<SyncResponse> syncOnlineToLocal(Account acc,
      {bool firstTime = false}) async {
    Lemmy lemmyClient = Lemmy(acc.instance);

    String? password =
        await CredentialUtils.get("${acc.username}@${acc.instance}");
    if (password == null || password.isEmpty) {
      Logger.error(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
      callLogHandler(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
      throw Exception(
          "Unable to retrieve password for account ${acc.username}@${acc.instance}");
    }

    acc.password = password;

    //callLogHandler("Authenticating to ${acc.username}@${acc.instance}");
    var loginResult = await lemmyClient.login(acc.username, acc.password!);
    if (!loginResult) {
      callLogHandler(
          "Login failed for account ${acc.username}@${acc.instance}, have you changed the password?");
      throw Exception(
          "Login failed for account ${acc.username}@${acc.instance}, have you changed the password?");
    }
    CommunityRepo communityRepo = CommunityRepo(dbConnection: _dbConnection);

    callLogHandler(
        "Fetching remote communities from ${acc.username}@${acc.instance}");
    List<String> onlineCommunities = [];
    try {
      onlineCommunities = await lemmyClient.getCommunities();
    } catch (e) {
      callLogHandler(
          "Couldn't retrieve communities from ${acc.username}@${acc.instance}");
      throw Exception(
          "Couldn't retrieve communities from ${acc.username}@${acc.instance}");
    }

    var localCommunities = await communityRepo
        .getAllFromAccount(acc.id!, acc.lastSync ?? DateTime.now())
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
        callLogHandler("Saving remote updates");
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
        callLogHandler("Failed to save updates");
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
