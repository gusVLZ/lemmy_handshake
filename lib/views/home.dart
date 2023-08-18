import 'package:flutter/material.dart';
import 'package:lemmy_handshake/model/account.dart';
import 'package:lemmy_handshake/repository/account_repo.dart';
import 'package:lemmy_handshake/util/db.dart';
import 'package:lemmy_handshake/util/scaffold_message.dart';
import 'package:lemmy_handshake/widgets/account_item.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Db _dbHelper = Db();
  List<Account> accounts = [];

  void _addAccount() {
    Navigator.of(context)
        .pushNamed("add_account")
        .then((value) => refreshAccounts());
  }

  Future<void> refreshAccounts() async {
    _dbHelper.startDatabase().then((dbConnection) => {
          AccountRepo(dbConnection: dbConnection).getAll().then((accs) {
            setState(() {
              accounts = accs;
            });
          })
        });
  }

  void showMessage(String message) {
    ScaffoldMessage(context).showScaffoldMessage(message);
  }

  @override
  void initState() {
    refreshAccounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Lemmy Handshake",
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: RefreshIndicator(
                onRefresh: () => refreshAccounts(),
                child: accounts.isEmpty
                    ? Text(
                        'No accounts binded, add two at least to sync them',
                        style: Theme.of(context).textTheme.labelLarge,
                      )
                    : ListView(
                        children: [
                          ...accounts
                              .map((e) => AccountItem(
                                    account: e,
                                    onDelete: refreshAccounts,
                                  ))
                              .toList(),
                          OutlinedButton(
                              onPressed: (() => Navigator.of(context)
                                  .pushNamed("sync_accounts")
                                  .then((value) => refreshAccounts())),
                              child: const Text("Sync")),
                          OutlinedButton(
                              onPressed: () {
                                Db()
                                    .purgeDataBase()
                                    .then((value) => refreshAccounts());
                              },
                              child: const Text("DELETE DB"))
                        ],
                      ),
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        tooltip: 'Add account',
        child: const Icon(Icons.add),
      ),
    );
  }
}
