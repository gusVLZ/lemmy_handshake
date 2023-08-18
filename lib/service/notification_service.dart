import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static registerChannels() {}

  static Future showNotificationWithDefaultSound(
      FlutterLocalNotificationsPlugin notificationClient,
      int totalExecutions) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'lemmy_account_sync', 'Synchronization of Lemmy Accounts',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(
            '${totalExecutions.toString()}: Currently syncing lemmy accounts in background'));

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await notificationClient.show(
      0,
      'Lemmy Account Synchronization',
      "",
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
}
