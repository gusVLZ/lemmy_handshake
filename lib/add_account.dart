import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/model/person_view.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/lemmy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemmy_account_sync/util/sync_motor.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  AddAccountState createState() => AddAccountState();
}

enum MessageTypes { error, success, info }

class AddAccountState extends State<AddAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _instanceController =
      TextEditingController(text: "sh.itjust.works");
  final TextEditingController _usernameController =
      TextEditingController(text: "gusVLZ");
  final TextEditingController _passwordController = TextEditingController();

  final storage = const FlutterSecureStorage();

  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _instanceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<int> _saveAccount(PersonView userData) async {
    var account = Account(
        externalId: userData.person.id.toString(),
        username: userData.person.name,
        instance: _instanceController.text,
        nuComment: userData.counts.commentCount,
        nuSubscription: 0,
        nuPost: userData.counts.postCount,
        lastSync: null,
        profileUrl: userData.person.avatar);
    var accountId = Db().getDatabase().then(
          (dbConnection) => AccountRepo(dbConnection: dbConnection)
              .insert(account)
              .then(
                (insertId) => storage
                    .write(
                        key:
                            '${userData.person.name}@${_instanceController.text}',
                        value: _passwordController.text)
                    .then(
                  (value) async {
                    showScaffoldMessage(
                        'Saved, now syncing communities of this account');
                    account.id = insertId;
                    await SyncMotor(dbConnection).syncOnlineToLocal(account);
                    return insertId;
                  },
                ),
              ),
        );

    return accountId;
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showScaffoldMessage(
      String message,
      {MessageTypes type = MessageTypes.info,
      Duration duration = const Duration(seconds: 3)}) {
    Color textColor;
    Color backgroundColor;

    switch (type) {
      case MessageTypes.success:
        textColor = Theme.of(context).colorScheme.onPrimaryContainer;
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        break;
      case MessageTypes.info:
        textColor = Theme.of(context).colorScheme.onSecondaryContainer;
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        break;
      case MessageTypes.error:
        textColor = Colors.black;
        backgroundColor = Colors.red[200]!;
        break;
      default:
        textColor = Colors.black;
        backgroundColor = Colors.white;
    }

    var loadingController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message, style: TextStyle(color: textColor))),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );

    return loadingController;
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    showScaffoldMessage('Connecting to instance and login you in');

    setState(() {
      _isLoading = true;
    });

    Lemmy lemmy = Lemmy(_instanceController.text);
    lemmy
        .login(_usernameController.text, _passwordController.text)
        .then((loginResponse) {
      if (!loginResponse) {
        showScaffoldMessage('Error: check your credentials and instance url',
            type: MessageTypes.error);
        setState(() {
          _isLoading = false;
        });
        return;
      }
      showScaffoldMessage('Logged, getting used data');
      lemmy.getUserData(_usernameController.text).then((userData) {
        if (userData == null) {
          showScaffoldMessage('Error: unable to get user data',
              type: MessageTypes.error);
          return;
        }
        showScaffoldMessage('Got user data, saving to local storage');
        _saveAccount(userData).then((value) {
          if (value == 0) {
            showScaffoldMessage('Error: unable to save account data',
                type: MessageTypes.error);
            return;
          }
          setState(() {
            _isLoading = false;
          });
          Navigator.popAndPushNamed(context, "home");
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to account'),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  enabled: !_isLoading,
                  controller: _instanceController,
                  autocorrect: false,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Instance'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_isLoading,
                  controller: _usernameController,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  enabled: !_isLoading,
                  controller: _passwordController,
                  autocorrect: false,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      suffixIcon: TextButton(
                          onPressed: (() =>
                              {setState(() => _hidePassword = !_hidePassword)}),
                          child: Text(_hidePassword ? "show" : "hide")),
                      border: const OutlineInputBorder(),
                      labelText: 'Password'),
                  obscureText: _hidePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () => !_isLoading ? _submitForm(context) : () {},
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator.adaptive())
                      : const Text('Add account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
