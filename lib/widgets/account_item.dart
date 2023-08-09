import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/model/account_details.dart';

class AccountItem extends StatelessWidget {
  final AccountDetails accountDetails;
  const AccountItem({Key? key, required this.accountDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: Image.network(accountDetails.profileUrl),
        title: Text('${accountDetails.username}@${accountDetails.instance}'),
      ),
    );
  }
}
