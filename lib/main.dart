import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/add_account.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/sync_accounts.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/scaffold_message.dart';
import 'package:lemmy_account_sync/widgets/account_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.purple);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.purple, brightness: Brightness.dark);
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Lemmy Account Sync',
          theme: ThemeData(
            colorScheme: lightColorScheme ?? _defaultLightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme ?? _defaultDarkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.dark,
          home: const MyHomePage(),
          routes: {
            "home": (context) => const MyHomePage(),
            "add_account": (context) => const AddAccount(),
            "sync_accounts": (context) => const SyncAccounts()
          },
          debugShowCheckedModeBanner: false,
        );
      },
    );
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
          "Lemmy Account Sync",
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
