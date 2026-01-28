import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapSpaIdController =
      StreamController<String>.broadcast();
  AndroidNotificationChannel? _androidChannel;

  Stream<String> onTapSpaId() => _tapSpaIdController.stream;

  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    final initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload ?? '';
        if (payload.isNotEmpty) {
          _tapSpaIdController.add(payload);
        }
      },
    );
    _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications.',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel!);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future<void> showRemoteMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    final spaId = message.data['spaId']?.toString() ?? '';
    final androidDetails = AndroidNotificationDetails(
      _androidChannel?.id ?? 'high_importance_channel',
      _androidChannel?.name ?? 'High Importance Notifications',
      channelDescription: _androidChannel?.description,
      priority: Priority.high,
      importance: Importance.max,
      ticker: 'ticker',
    );
    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
      payload: spaId,
    );
  }
}
