import 'dart:io';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:lemmy_handshake/service/work_service.dart';
import 'package:lemmy_handshake/views/add_account.dart';
import 'package:lemmy_handshake/views/home.dart';
import 'package:lemmy_handshake/views/sync_accounts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return WorkService.taskLogicExecutor(task, inputData);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  sqfliteFfiInit();
  if (Platform.isWindows) {
    databaseFactory = databaseFactoryFfi;
  }

  WorkService.initialize(callbackDispatcher);

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
          title: 'Lemmy Handshake',
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
