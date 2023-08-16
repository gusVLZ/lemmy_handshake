import 'package:flutter/material.dart';
import 'package:get_time_ago/get_time_ago.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/widgets/confirmation.dart';

class AccountItem extends StatelessWidget {
  final Account account;
  final VoidCallback onDelete;

  const AccountItem({Key? key, required this.account, required this.onDelete})
      : super(key: key);

  void deleteAccount() {
    Db()
        .getDatabase()
        .then((dbConnection) =>
            AccountRepo(dbConnection: dbConnection).delete(account.id!))
        .then((deleted) => onDelete());
  }

  void editAccount() {}

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderOnForeground: true,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.username,
                        style: Theme.of(context).primaryTextTheme.displaySmall),
                    Text(account.instance,
                        style: Theme.of(context).primaryTextTheme.titleMedium),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text("Edit"),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text("Delete"),
                      ),
                    ];
                  },
                  onSelected: (value) {
                    if (value == 1) {
                      Confirmation.showConfirmationDialog(context,
                          title: "Remove account?",
                          message: "The account won't be synced anymore",
                          callbackOnConfirm: deleteAccount);
                    } else if (value == 0) {}
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Communities: ${account.nuSubscription}"),
                Text("Posts: ${account.nuPost}"),
                Text("Comments: ${account.nuComment}"),
              ],
            ),
            Text(
                "Last sync: ${account.lastSync != null ? GetTimeAgo.parse(account.lastSync!) : "never"}")
          ],
        ),
      ),
    );
  }
}
