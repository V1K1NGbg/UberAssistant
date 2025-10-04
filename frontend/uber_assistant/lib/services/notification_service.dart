import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart' as fgt;

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelIdOffers = 'offers';
  static const _channelIdOnline = 'online_status';

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) {
        // handle payloads if needed
      },
    );

    if (Platform.isAndroid) {
      final offers = const AndroidNotificationChannel(
        _channelIdOffers,
        'Ride Offers',
        description: 'Offer alerts with sound and vibration',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      final online = const AndroidNotificationChannel(
        _channelIdOnline,
        'Online Status',
        description: 'Persistent status while Available',
        importance: Importance.low,
        playSound: false,
        enableVibration: false,
      );
      final androidImpl =
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(offers);
      await androidImpl?.createNotificationChannel(online);
    }
  }

  Future<void> showOffer({
    required String title,
    required String body,
  }) async {
    // cross-platform haptic (built into Flutter)
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}

    await _plugin.show(
      1001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelIdOffers,
          'Ride Offers',
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

  // Persistent Android notification + foreground service
  Future<void> startOnlineService() async {
    if (!Platform.isAndroid) return;

    fgt.FlutterForegroundTask.init(
      androidNotificationOptions: fgt.AndroidNotificationOptions(
        channelId: _channelIdOnline,
        channelName: 'Online Status',
        channelDescription: 'Keeps the app active while Available',
        channelImportance: fgt.NotificationChannelImportance.LOW,
        priority: fgt.NotificationPriority.LOW,
        isSticky: true,
        visibility: fgt.NotificationVisibility.VISIBILITY_PUBLIC,
        iconData: const fgt.NotificationIconData(
          resType: fgt.ResourceType.mipmap,
          resPrefix: fgt.ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const fgt.IOSNotificationOptions(showNotification: false),
      foregroundTaskOptions: const fgt.ForegroundTaskOptions(interval: 5000),
    );

    await fgt.FlutterForegroundTask.startService(
      notificationTitle: 'Available',
      notificationText: 'Staying connected for offers',
    );
  }

  Future<void> stopOnlineService() async {
    if (!Platform.isAndroid) return;
    await fgt.FlutterForegroundTask.stopService();
  }
}
