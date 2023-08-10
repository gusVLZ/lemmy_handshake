import 'dart:core';

class Account {
  final String accountId;
  final String username;
  final String instance;
  DateTime? lastSync;
  String? profileUrl;
  Account({
    required this.accountId,
    required this.username,
    required this.instance,
    this.lastSync,
    this.profileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'username': username,
      'instance': instance,
      'lastSync': lastSync?.toIso8601String(),
      'profileUrl': profileUrl,
    };
  }
}
