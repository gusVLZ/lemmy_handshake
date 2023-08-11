import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/add_account.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/sync_motor.dart';
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
        home: const MyHomePage(),
        routes: {
          "home": (context) => const MyHomePage(),
          "add_account": (context) => const AddAccount()
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Db _dbHelper = Db();
  List<Account> accounts = [];

  void _addAccount() {
    Navigator.of(context).pushNamed("add_account");
  }

  void refreshAccounts() {
    _dbHelper.startDatabase().then((dbConnection) => {
          AccountRepo(dbConnection: dbConnection).getAll().then((accs) {
            setState(() {
              accounts = accs;
            });
          })
        });
  }

  void _syncItAll() {
    SyncMotor.createAsync().then((value) => value.syncAccounts());
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
          "Lemmy Account Sync",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[600],
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: accounts.isEmpty
            ? Text(
                'No accounts binded, add two at least to sync them',
                style: Theme.of(context).textTheme.labelLarge,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ...accounts
                      .map((e) => AccountItem(
                            account: e,
                            onDelete: refreshAccounts,
                          ))
                      .toList(),
                  OutlinedButton(onPressed: _syncItAll, child: Text("Sync"))
                ],
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
