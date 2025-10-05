import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' as fgt;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelIdOffers = 'offers';
  static const _channelIdOnline = 'online_status';
  static const _channelIdAlerts = 'alerts';

  static const _onlineNotifId = 2001;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(InitializationSettings(android: android, iOS: ios));

    if (Platform.isAndroid) {
      final offers = const AndroidNotificationChannel(
        _channelIdOffers, 'Ride Offers',
        description: 'Offer alerts with sound and vibration',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      final online = const AndroidNotificationChannel(
        _channelIdOnline, 'Online Status',
        description: 'Persistent status while Available',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );
      final alerts = const AndroidNotificationChannel(
        _channelIdAlerts, 'Alerts',
        description: 'Important alerts',
        importance: Importance.high,
      );
      final impl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await impl?.createNotificationChannel(offers);
      await impl?.createNotificationChannel(online);
      await impl?.createNotificationChannel(alerts);
    }
  }

  Future<void> showOffer({required String title, required String body}) async {
    await _plugin.show(
      1001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelIdOffers, 'Ride Offers',
          priority: Priority.max,
          importance: Importance.max,
          enableVibration: true,
          styleInformation: const BigTextStyleInformation(''),
          category: AndroidNotificationCategory.call,
        ),
        iOS: const DarwinNotificationDetails(presentSound: true),
      ),
      payload: 'offer',
    );
  }

  Future<void> showAlert({required String title, required String body}) async {
    await _plugin.show(
      1999,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(_channelIdAlerts, 'Alerts'),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Foreground service + an ongoing local notification.
  Future<void> startOnlineService() async {
    if (Platform.isAndroid) {
      fgt.FlutterForegroundTask.init(
        androidNotificationOptions: fgt.AndroidNotificationOptions(
          channelId: _channelIdOnline,
          channelName: 'Online Status',
          channelDescription: 'Keeps the app active while Available',
          channelImportance: fgt.NotificationChannelImportance.LOW,
          priority: fgt.NotificationPriority.LOW,
          visibility: fgt.NotificationVisibility.VISIBILITY_PUBLIC,
        ),
        iosNotificationOptions: const fgt.IOSNotificationOptions(showNotification: false),
        foregroundTaskOptions: const fgt.ForegroundTaskOptions(interval: 5000),
      );

      await fgt.FlutterForegroundTask.startService(
        notificationTitle: 'Available',
        notificationText: 'Staying connected for offers',
      );

      // Ongoing notification while online
      await _plugin.show(
        _onlineNotifId,
        'Available',
        'Staying connected for offers',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelIdOnline, 'Online Status',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            category: AndroidNotificationCategory.service,
            showWhen: false,
          ),
        ),
      );
    }
  }

  Future<void> stopOnlineService() async {
    if (Platform.isAndroid) {
      await fgt.FlutterForegroundTask.stopService();
      await _plugin.cancel(_onlineNotifId);
    }
  }
}
