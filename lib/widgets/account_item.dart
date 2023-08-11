import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/date_util.dart';
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
            AccountRepo(dbConnection: dbConnection).delete(account.accountId))
        .then((deleted) => onDelete());
  }

  void editAccount() {}

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      borderOnForeground: true,
      elevation: 3,
      shadowColor: Colors.green[200],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                account.profileUrl != null
                    ? Image.network(
                        account.profileUrl!,
                        width: 42,
                      )
                    : const Image(
                        image: AssetImage("assets/lemmy.png"),
                        width: 42,
                      ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${account.username}@${account.instance}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                            "Last Sync: ${account.lastSync?.toString() ?? DateUtil(context).formatDateTimeToLocalString(DateTime.now())}"),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          const Divider(
            color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Subscriptions: ${account.nuSubscription}",
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Posts: ${account.nuPost}",
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        "Comments: ${account.nuComment}",
                        textAlign: TextAlign.left,
                      )
                    ]),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                  padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.edit),
                  onPressed: editAccount,
                ),
                IconButton(
                  padding: const EdgeInsets.all(16),
                  icon: const Icon(Icons.close),
                  onPressed: () => Confirmation.showConfirmationDialog(context,
                      title: "Remove account?",
                      message: "The account won't be synced anymore",
                      callbackOnConfirm: deleteAccount),
                )
              ])
            ],
          ),
        ],
      ),
    );
  }
}
