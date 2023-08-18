import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static RegisterChannels() {}

  static Future showNotificationWithDefaultSound(
      FlutterLocalNotificationsPlugin notificationClient,
      int totalExecutions) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'lemmy_account_sync', 'Synchronization of Lemmy Accounts',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority);

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await notificationClient.show(
      0,
      'Lemmy Account Synchronization',
      'Currently syncing lemmy accounts in background, Execution number: ${totalExecutions.toString()}',
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
}
