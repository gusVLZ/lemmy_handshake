import 'dart:core';

class Account {
  int? id;
  final String externalId;
  final String username;
  String? password;
  final String instance;
  final int nuSubscription;
  final int nuPost;
  final int nuComment;
  DateTime? lastSync;
  String? profileUrl;
  Account({
    this.id,
    required this.externalId,
    required this.username,
    this.password,
    required this.instance,
    required this.nuSubscription,
    required this.nuPost,
    required this.nuComment,
    this.lastSync,
    this.profileUrl,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      externalId: json['accountId'],
      username: json['username'],
      instance: json['instance'],
      lastSync: json['lastSync'],
      nuSubscription: json['nuSubscription'],
      nuPost: json['nuPost'],
      nuComment: json['nuComment'],
      profileUrl: json['profileUrl'],
    );
  }

  factory Account.fromDb(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      externalId: json['externalId'],
      username: json['username'],
      instance: json['instance'],
      lastSync: DateTime.tryParse(json['lastSync'] ?? ""),
      nuSubscription: json['nuSubscription'],
      nuPost: json['nuPost'],
      nuComment: json['nuComment'],
      profileUrl: json['profileUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'externalId': externalId,
      'username': username,
      'instance': instance,
      'nuSubscription': nuSubscription,
      'nuPost': nuPost,
      'nuComment': nuComment,
      'lastSync': lastSync?.toIso8601String(),
      'profileUrl': profileUrl,
    };
  }
}
