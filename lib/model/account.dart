import 'dart:core';

class Account {
  final String accountId;
  final String username;
  final String password;
  final String instance;
  final int nuSubscription;
  final int nuPost;
  final int nuComment;
  DateTime? lastSync;
  String? profileUrl;
  Account({
    required this.accountId,
    required this.username,
    required this.password,
    required this.instance,
    required this.nuSubscription,
    required this.nuPost,
    required this.nuComment,
    this.lastSync,
    this.profileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'username': username,
      'password': password,
      'instance': instance,
      'nuSubscription': nuSubscription,
      'nuPost': nuPost,
      'nuComment': nuComment,
      'lastSync': lastSync?.toIso8601String(),
      'profileUrl': profileUrl,
    };
  }
}
