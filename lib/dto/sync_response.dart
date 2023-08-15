class SyncResponse {
  final List<String> added;
  final List<String> removed;
  final List<String> failedToAdd;
  final List<String> failedToRemove;
  final String accountId;
  final DateTime when;
  SyncResponse(
      {required this.accountId,
      required this.added,
      required this.failedToAdd,
      required this.failedToRemove,
      required this.removed,
      required this.when});

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'added': added,
      'removed': removed,
      'failedToAdd': failedToAdd,
      'failedToRemove': failedToRemove,
      'when': when.toIso8601String(),
    };
  }
}
