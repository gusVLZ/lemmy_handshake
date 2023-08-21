import 'package:lemmy_handshake/service/notification_service.dart';
import 'package:lemmy_handshake/util/logger.dart';
import 'package:lemmy_handshake/util/sync_motor.dart';
import 'package:workmanager/workmanager.dart';

class WorkService {
  static void initialize(Function callbackDispatcher) {
    Workmanager().initialize(callbackDispatcher);

    Logger.info("Registering background services");
    Workmanager().registerPeriodicTask("sync-task", "syncTask",
        //constraints: Constraints(networkType: NetworkType.connected),
        initialDelay: const Duration(minutes: 1),
        frequency: const Duration(minutes: 15)); //6 times per day
  }

  static Future<bool> taskLogicExecutor(
      String task, Map<String, dynamic>? inputData) async {
    Logger.info("Native called background task: $task");
    switch (task) {
      case "syncTask":
        try {
          var notificationClient = NotificationService.initialize();
          NotificationService.showSyncingNotification(notificationClient);

          var syncMotor = await SyncMotor.createAsync();
          var result = await syncMotor.syncAccounts();

          NotificationService.hideNotification(notificationClient, 0);

          if (result.hasContent()) {
            NotificationService.showSyncResultNotification(
              notificationClient,
              subscribed: result.added.length,
              unsubscribed: result.removed.length,
            );
          }
        } catch (err) {
          Logger.error(err.toString());
          throw Exception(err);
        }
        break;
      default:
    }

    return Future.value(true);
  }
}
