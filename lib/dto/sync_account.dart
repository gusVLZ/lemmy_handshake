import 'package:lemmy_account_sync/model/account.dart';

class SyncAccount {
  final Account account;
  final Set<String> toAdd;
  final Set<String> toDelete;
  SyncAccount(
      {required this.account, required this.toAdd, required this.toDelete});
}
