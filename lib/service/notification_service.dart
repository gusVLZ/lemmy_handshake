import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin initialize() {
    FlutterLocalNotificationsPlugin notificationClient =
        FlutterLocalNotificationsPlugin();

    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const DarwinInitializationSettings();

    var settings = InitializationSettings(android: android, iOS: iOS);
    notificationClient.initialize(settings);

    return notificationClient;
  }

  static Future showSyncResultNotification(
    FlutterLocalNotificationsPlugin notificationClient, {
    int? subscribed,
    int? unsubscribed,
    int? saved,
    int? banned,
  }) async {
    String notificationText = "Accounts synchronized!";
    if (subscribed != null && subscribed > 0) {
      notificationText += "\nSubscribed: $subscribed";
    }
    if (unsubscribed != null && unsubscribed > 0) {
      notificationText += "\nUnsubscribed: $unsubscribed";
    }
    if (saved != null && saved > 0) {
      notificationText += "\nSaved: $saved";
    }
    if (banned != null && banned > 0) {
      notificationText += "\nBanned: $banned";
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'lemmy_handshake_result', 'Synchronization result',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        styleInformation: BigTextStyleInformation(notificationText));

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await notificationClient.show(
      1,
      'Lemmy Handshakehronization',
      "",
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  static Future showSyncingNotification(
      FlutterLocalNotificationsPlugin notificationClient) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'lemmy_handshake', 'Synchronization of Lemmy Accounts',
        importance: Importance.low,
        priority: Priority.low,
        autoCancel: true,
        playSound: false,
        channelShowBadge: false);

    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await notificationClient.show(
      0,
      'Lemmy Handshakehronization',
      "Syncing...",
      platformChannelSpecifics,
    );
  }

  static Future hideNotification(
      FlutterLocalNotificationsPlugin notificationClient,
      int notificationId) async {
    notificationClient.cancel(notificationId);
  }
}
