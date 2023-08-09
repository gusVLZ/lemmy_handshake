import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/add_account.dart';
import 'package:lemmy_account_sync/model/account_details.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/widgets/account_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lemmy Account Sync',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.green,
        ),
        home: const MyHomePage(title: 'Lemmy Account Sync'),
        routes: {"add_account": (context) => const AddAccount()});
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Db _dbHelper = Db();
  List<AccountDetails> accounts = [];

  void _addAccount() {
    Navigator.of(context).pushNamed("add_account");
  }

  @override
  void initState() {
    _dbHelper.startDatabase();
    // TODO: buscar contas cadastradas localmente e popular obj contas

    accounts.add(AccountDetails(
        accountId: "accountId",
        username: "username",
        instance: "instance",
        lastSync: DateTime.now(),
        profileUrl:
            "https://user-images.githubusercontent.com/7890201/114214731-50e82780-992a-11eb-9e64-0397c2527b29.png"));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: accounts.isEmpty
            ? Text(
                'No accounts binded, add two at least to sync them',
                style: Theme.of(context).textTheme.labelLarge,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: accounts
                    .map((e) => AccountItem(accountDetails: e))
                    .toList(),
              ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        tooltip: 'Add account',
        child: const Icon(Icons.add),
      ),
    );
  }
}
