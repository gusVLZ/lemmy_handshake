import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemmy_handshake/service/work_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settings_ui/settings_ui.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  final storage = const FlutterSecureStorage();
  SharedPreferences? shared;

  bool? isNotificationActive;
  bool? isUnfollowAllowed;
  bool? isBackgroundActive;

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        shared = value;
        isNotificationActive = shared!.getBool("is_notification_active");
        isUnfollowAllowed = shared!.getBool("is_unfollow_allowed");
        isBackgroundActive = shared!.getBool("is_background_active");
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void toggleBackgroundService(bool value) {
    if (value) {
      WorkService.start();
    } else {
      WorkService.stop();
    }
    shared!.setBool("is_background_active", value);
    setState(() {
      isBackgroundActive = value;
    });
  }

  void toggleNotification(bool value) {
    shared!.setBool("is_notification_active", value);
    setState(() {
      isNotificationActive = value;
    });
  }

  void toggleUnfollow(bool value) {
    shared!.setBool("is_unfollow_allowed", value);
    setState(() {
      isUnfollowAllowed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: shared != null
          ? SettingsList(
              sections: [
                SettingsSection(
                  title: const Text('Sync'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: toggleBackgroundService,
                      initialValue: isBackgroundActive,
                      leading: const Icon(Icons.sync),
                      title: const Text('Background syncronization'),
                    ),
                    SettingsTile.switchTile(
                      onToggle: toggleUnfollow,
                      initialValue: isUnfollowAllowed,
                      leading: const Icon(Icons.remove_circle),
                      title: const Text('Allow community unfollow'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: const Text('Notification'),
                  tiles: <SettingsTile>[
                    SettingsTile.switchTile(
                      onToggle: toggleNotification,
                      initialValue: isNotificationActive,
                      leading: const Icon(Icons.notifications),
                      title: const Text('Show notifications'),
                    ),
                  ],
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
