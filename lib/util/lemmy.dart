import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
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

  Future<void> login(String user, String password) async {
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
    } catch (e) {
      _println(1, "[ERROR]: login() failed for $user on $_siteUrl");
      _println(2, "-Details: $e");
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
          Logger.info(url);
        });
      } catch (err) {
        Logger.error("error: $err");
      }
    }

    _userCommunities = userCommunities.toSet();
    return userCommunities;
  }

  Future<void> _rateLimit() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<http.Response> _requestIt(
    Uri endpoint, {
    String method = "GET",
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
  }) async {
    await _rateLimit();
    try {
      Response response = Response("Method not allowed", 405);
      if (method == "GET") {
        response = await http.get(
          endpoint.replace(queryParameters: queryParams),
          headers: {"Content-Type": "application/json"},
        );
      }
      if (method == "POST") {
        response = await http.post(
          endpoint.replace(queryParameters: queryParams),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );
      }
      return response;
    } catch (e) {
      throw e;
    }
  }

  void _println(int indent, String line) {
    print("${' ' * indent}$line");
  }

  Future<void> subscribe(List<String> communities) async {
    Map<String, String> payload = {
      "community_id": "",
      "follow": "true",
      "auth": _authToken,
    };

    for (String url in communities) {
      try {
        // Resolve community first
        int? commId = await resolveCommunity(url);

        if (commId != null) {
          payload["community_id"] = commId.toString();
          _println(2, "> Subscribing to $url ($commId)");
          final response = await _requestIt(
            Uri.parse('$_siteUrl/$_apiBaseUrl/community/follow'),
            method: 'POST',
            body: payload,
          );

          if (response.statusCode == 200) {
            _userCommunities.add(commId.toString());
            _println(3, "> Successfully subscribed to $url ($commId)");
          }
        }
      } catch (e) {
        print("   API error: $e");
      }
    }
  }

  Future<int?> resolveCommunity(String community) async {
    Map<String, String> payload = {"q": community, "auth": _authToken};

    int? communityId;
    _println(1, "> Resolving $community");
    try {
      final response = await _requestIt(
        Uri.parse('$_siteUrl/$_apiBaseUrl/resolve_object'),
        queryParams: payload,
      );
      final jsonData = jsonDecode(response.body);
      communityId = jsonData["community"]["community"]["id"];
    } catch (e) {
      _println(2, "> Failed to resolve community $e");
    }

    return communityId;
  }

  Future<Map<String, dynamic>> getComments(String postId,
      {int maxDepth = 1, int limit = 1000}) async {
    Map<String, String> payload = {
      "post_id": postId,
      "max_depth": maxDepth.toString(),
      "limit": limit.toString(),
    };

    try {
      final response = await _requestIt(
        Uri.parse('$_siteUrl/$_apiBaseUrl/comment/list'),
        queryParams: payload,
      );
      final jsonData = jsonDecode(response.body);
      return jsonData["comments"];
    } catch (e) {
      _println(2, "> Failed to get comment list");
      return {};
    }
  }
}
