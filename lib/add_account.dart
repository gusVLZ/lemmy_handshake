import 'package:flutter/material.dart';
import 'package:lemmy_account_sync/model/account.dart';
import 'package:lemmy_account_sync/repository/account_repo.dart';
import 'package:lemmy_account_sync/util/db.dart';
import 'package:lemmy_account_sync/util/lemmy.dart';

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
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _instanceController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      var loadingController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Connecting to instance and login you in',
                  style: TextStyle(color: Colors.black))),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 15),
        ),
      );
      setState(() {
        _isLoading = true;
      });
      Lemmy lemmy = Lemmy(_instanceController.text);
      lemmy
          .login(_usernameController.text, _passwordController.text)
          .then((loginResponse) {
        loadingController.close();
        setState(() {
          _isLoading = false;
        });
        if (loginResponse) {
          lemmy.getUserData(_usernameController.text).then((userData) => {
                if (userData != null)
                  {
                    Db().startDatabase().then((dbConnection) => AccountRepo(
                            dbConnection: dbConnection)
                        .insertAccount(Account(
                            accountId: userData.person.id.toString(),
                            username: userData.person.name,
                            instance: _instanceController.text,
                            lastSync: null,
                            profileUrl: userData.person.avatar))
                        .then((value) => Navigator.pushNamed(context, "home")))
                  }
              });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Error: check your credentials and instance url',
                      style: TextStyle(color: Colors.white))),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
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
                  child: const Text('Add account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
