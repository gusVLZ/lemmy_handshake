import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemmy_account_sync/util/sync_motor.dart';

class SyncAccounts extends StatefulWidget {
  const SyncAccounts({Key? key}) : super(key: key);

  @override
  SyncAccountsState createState() => SyncAccountsState();
}

class SyncAccountsState extends State<SyncAccounts> {
  final _formKey = GlobalKey<FormState>();

  final storage = const FlutterSecureStorage();

  final List<String> _messages = [];

  void handleMessage(String message) {
    setState(() {
      _messages.add(message);
    });
  }

  void _syncItAll() {
    SyncMotor.createAsync(statusUpdateHandler: handleMessage).then((motor) =>
        motor.syncAccounts().then((syncResult) => Navigator.of(context).pop()));
  }

  @override
  void initState() {
    _syncItAll();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Synchronizing accounts'),
              CircularProgressIndicator()
            ]),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: _messages.map((e) => Text(e)).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
