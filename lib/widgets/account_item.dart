import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';

class AccountItem extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;

  const AccountItem({Key? key, required this.account, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: account.profileUrl != null
            ? Image.network(account.profileUrl!)
            : const Icon(Icons.account_circle),
        title: Text('${account.username}@${account.instance}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => Db()
              .getDatabase()
              .then((dbConnection) => AccountRepo(dbConnection: dbConnection)
                  .deleteAccount(account.accountId))
              .then((deleted) => onDelete()),
        ),
      ),
    );
  }
}
