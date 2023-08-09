import 'dart:core';

class AccountDetails {
  final String accountId;
  final String username;
  final String instance;
  final DateTime lastSync;
  final String profileUrl;
  AccountDetails({
    required this.accountId,
    required this.username,
    required this.instance,
    required this.lastSync,
    required this.profileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'username': username,
      'instance': instance,
      'lastSync': lastSync.toIso8601String(),
      'profileUrl': profileUrl,
    };
  }
}
