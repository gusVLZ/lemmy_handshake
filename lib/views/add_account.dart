import 'package:flutter/material.dart';
import 'package:lemmy_handshake/model/account.dart';
import 'package:lemmy_handshake/model/person_view.dart';
import 'package:lemmy_handshake/repository/account_repo.dart';
import 'package:lemmy_handshake/util/credential_utils.dart';
import 'package:lemmy_handshake/util/db.dart';
import 'package:lemmy_handshake/util/lemmy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemmy_handshake/util/scaffold_message.dart';
import 'package:lemmy_handshake/util/sync_motor.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  AddAccountState createState() => AddAccountState();
}

class AddAccountState extends State<AddAccount> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _instanceController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
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
          (dbConnection) =>
              AccountRepo(dbConnection: dbConnection).insert(account).then(
                    (insertId) => CredentialUtils.save(
                            "${userData.person.name}@${_instanceController.text}",
                            _passwordController.text)
                        .then(
                      (value) async {
                        ScaffoldMessage(context).showScaffoldMessage(
                            'Saved, now syncing communities of this account');
                        account.id = insertId;
                        await SyncMotor(dbConnection)
                            .syncOnlineToLocal(account, firstTime: true);
                        return insertId;
                      },
                    ),
                  ),
        );

    return accountId;
  }

  void _submitForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    ScaffoldMessage(context)
        .showScaffoldMessage('Connecting to instance and login you in');

    setState(() {
      _isLoading = true;
    });

    Lemmy lemmy = Lemmy(_instanceController.text);
    lemmy
        .login(_usernameController.text, _passwordController.text)
        .then((loginResponse) {
      if (!loginResponse) {
        ScaffoldMessage(context).showScaffoldMessage(
            'Error: check your credentials and instance url',
            type: MessageTypes.error);
        setState(() {
          _isLoading = false;
        });
        return;
      }
      ScaffoldMessage(context).showScaffoldMessage('Logged, getting used data');
      lemmy.getUserData(_usernameController.text).then((userData) {
        if (userData == null) {
          ScaffoldMessage(context).showScaffoldMessage(
              'Error: unable to get user data',
              type: MessageTypes.error);
          return;
        }
        ScaffoldMessage(context)
            .showScaffoldMessage('Got user data, saving to local storage');
        _saveAccount(userData).then((value) {
          if (value == 0) {
            ScaffoldMessage(context).showScaffoldMessage(
                'Error: unable to save account data',
                type: MessageTypes.error);
            return;
          }
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pop();
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
                  onFieldSubmitted: (value) => _submitForm(context),
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
