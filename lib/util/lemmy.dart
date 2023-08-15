import 'package:http/http.dart';
import 'package:lemmy_account_sync/dto/sync_response.dart';
import 'package:lemmy_account_sync/model/person_view.dart';
import 'dart:convert';

import 'package:lemmy_account_sync/util/logger.dart'; // For JSON parsing

class Lemmy {
  static const String _apiVersion = "v3";
  final String _apiBaseUrl = "api/$_apiVersion";
  late String _siteUrl;
  late String _authToken;
  Set<String> _userCommunities = {};

  Lemmy(String url) {
    Uri parsedUrl = Uri.parse(url);
    String urlPath =
        parsedUrl.host.isNotEmpty ? parsedUrl.host : parsedUrl.path;
    _siteUrl = Uri(
      scheme: "https",
      host: urlPath,
      path: "",
    ).toString();
  }

  Future<bool> login(String user, String password) async {
    Map<String, String> payload = {
      "username_or_email": user,
      "password": password,
    };

    try {
      final response = await _requestIt(
        Uri.parse("$_siteUrl/$_apiBaseUrl/user/login"),
        method: "POST",
        body: payload,
      );
      final jsonData = jsonDecode(response.body);
      _authToken = jsonData["jwt"];
      Logger.debug("logado com sucesso lol: $_authToken");
      return true;
    } catch (e) {
      Logger.error("[ERROR]: login() failed for $user on $_siteUrl");
      return false;
    }
  }

  Future<List<String>> getCommunities({String type = "Subscribed"}) async {
    List<String> userCommunities = [];

    int page = 1;
    Map<String, String> payload = {
      "type_": type,
      "auth": _authToken,
      "limit": "50",
      "page": page.toString(),
    };

    int fetched = 50; // max limit
    while (fetched == 50) {
      try {
        final response = await _requestIt(
          Uri.parse("$_siteUrl/$_apiBaseUrl/community/list"),
          queryParams: payload,
        );
        final jsonData = jsonDecode(response.body);
        fetched = jsonData["communities"].length;
        payload["page"] = (++page).toString();
        jsonData["communities"].forEach((comm) {
          String url = comm["community"]["actor_id"];
          userCommunities.add(url);
        });
      } catch (err) {
        Logger.error("error: $err");
      }
    }

    _userCommunities = userCommunities.toSet();
    return userCommunities;
  }

  Future<void> _rateLimit() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<Response> _requestIt(
    Uri endpoint, {
    String method = "GET",
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    await _rateLimit();
    try {
      Response response = Response("Method not allowed", 405);
      if (method == "GET") {
        response = await get(
          endpoint.replace(queryParameters: queryParams),
          headers: {"Content-Type": "application/json"},
        ).timeout(const Duration(seconds: 15));
      }
      if (method == "POST") {
        response = await post(
          endpoint.replace(queryParameters: queryParams),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<SyncResponse> subscribe(List<String> communities,
      {bool follow = true}) async {
    Map<String, dynamic> payload = {
      "community_id": 0,
      "follow": follow,
      "auth": _authToken,
    };

    var syncResponse = SyncResponse(
      accountId: _siteUrl,
      added: [],
      removed: [],
      failedToAdd: [],
      failedToRemove: [],
      when: DateTime.now(),
    );

    for (String url in communities) {
      try {
        // Resolve community first
        int? commId = await resolveCommunity(url);

        if (commId != null) {
          payload["community_id"] = commId;
          Logger.info("> Subscribing to $url ($commId)");
          final response = await _requestIt(
            Uri.parse('$_siteUrl/$_apiBaseUrl/community/follow'),
            method: 'POST',
            body: payload,
          );

          if (response.statusCode == 200) {
            if (follow) {
              _userCommunities.add(commId.toString());
              Logger.info("> Successfully subscribed to $url ($commId)");
              syncResponse.added.add(url);
            } else {
              _userCommunities.remove(commId.toString());
              Logger.info("> Successfully unsubscribed to $url ($commId)");
              syncResponse.removed.add(url);
            }
          }
        }
      } catch (e) {
        Logger.error("API error: $e");
        if (follow) {
          syncResponse.failedToAdd.add(url);
        } else {
          syncResponse.failedToRemove.add(url);
        }
      }
    }

    return syncResponse;
  }

  Future<int?> resolveCommunity(String community) async {
    Map<String, String> payload = {"q": community, "auth": _authToken};

    int? communityId;
    Logger.info("> Resolving $community");
    try {
      final response = await _requestIt(
        Uri.parse('$_siteUrl/$_apiBaseUrl/resolve_object'),
        queryParams: payload,
      );
      final jsonData = jsonDecode(response.body);
      communityId = jsonData["community"]["community"]["id"];
    } catch (e) {
      Logger.info("> Failed to resolve community $e");
    }

    return communityId;
  }

  Future<PersonView?> getUserData(String username,
      {int limit = 1, int page = 1}) async {
    Map<String, String> payload = {
      "username": username,
      "page": page.toString(),
      "limit": limit.toString(),
    };

    try {
      final response = await _requestIt(
        Uri.parse('$_siteUrl/$_apiBaseUrl/user'),
        queryParams: payload,
      );
      final jsonData = jsonDecode(response.body);
      return PersonView.fromJson(jsonData["person_view"]);
    } catch (e) {
      Logger.error("> Failed to get user data: $e");
      return null;
    }
  }
}
