import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_windows_vault/flutter_windows_vault.dart';

class CredentialUtils {
  static Future<bool> save(String key, String password) async {
    if (Platform.isWindows) {
      return await FlutterWindowsVault.set(
          key: key, value: password, encrypted: true);
    } else {
      return const FlutterSecureStorage()
          .write(key: key, value: password)
          .then((value) => true);
    }
  }

  static Future<String?> get(String key) async {
    if (Platform.isWindows) {
      return FlutterWindowsVault.get(key: key, encrypted: true)
          .then((value) => value?.value);
    } else {
      return const FlutterSecureStorage().read(key: key);
    }
  }
}
