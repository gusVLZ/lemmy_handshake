import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemmy_account_sync/util/sync_motor.dart';

class SyncAccounts extends StatefulWidget {
  const SyncAccounts({Key? key}) : super(key: key);

  @override
  SyncAccountsState createState() => SyncAccountsState();
}

class SyncAccountsState extends State<SyncAccounts> {
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
          title: const Text('Synchronizing accounts'),
        ),
        body: ListView(
          children: [
            const LinearProgressIndicator(),
            ..._messages.map((e) => MessageWrapper(message: e)).toList()
          ],
        ));
  }
}

class MessageWrapper extends StatelessWidget {
  final String message;
  const MessageWrapper({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(message),
    );
  }
}
