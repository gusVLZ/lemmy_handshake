import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lemmy_account_sync/service/notification_service.dart';
import 'package:lemmy_account_sync/util/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class WorkService {
  static void initialize(Function callbackDispatcher) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

    Logger.info("Registering background services");
    Workmanager().registerPeriodicTask("task-identifier", "simplePeriodicTask",
        constraints: Constraints(networkType: NetworkType.connected));
    Workmanager().registerOneOffTask("task-test", "notificationTest",
        initialDelay: const Duration(seconds: 30));
  }

  static Future<bool> taskLogicExecutor(
      String task, Map<String, dynamic>? inputData) async {
    Logger.info("Native called background task: $task");

    int totalExecutions = 0;
    final sharedPreference = await SharedPreferences.getInstance();

    try {
      totalExecutions = sharedPreference.getInt("totalExecutions") ?? 0;
      sharedPreference.setInt("totalExecutions", totalExecutions + 1);

      FlutterLocalNotificationsPlugin notificationClient =
          FlutterLocalNotificationsPlugin();

      var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
      var iOS = const DarwinInitializationSettings();

      var settings = InitializationSettings(android: android, iOS: iOS);
      notificationClient.initialize(settings);
      NotificationService.showNotificationWithDefaultSound(
          notificationClient, totalExecutions);
    } catch (err) {
      Logger.error(err.toString());
      throw Exception(err);
    }

    return Future.value(true);
  }
}
