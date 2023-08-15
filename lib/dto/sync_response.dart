class SyncResponse {
  final List<String> added;
  final List<String> removed;
  final String accountId;
  final DateTime when;
  SyncResponse(
      {required this.accountId,
      required this.added,
      required this.removed,
      required this.when});

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'added': added,
      'removed': removed,
      'when': when.toIso8601String(),
    };
  }
}
