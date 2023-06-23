import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

import 'package:timezone/timezone.dart' as tz;

class NotificationServices {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();

  Future<void> initNotification() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('flutter_logo');
    var initilizationSettingIos = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {});
    var initilizationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: initilizationSettingIos);
    await _notifications.initialize(
      initilizationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            importance: Importance.max),
        iOS: DarwinNotificationDetails(
            sound: 'a_long_cold_sting.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true));
  }

  static Future showScheduledNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledTime,
  }) async {
    try {
      _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(
          scheduledTime,
          tz.local,
        ),
        await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException {
      log('Error');
    } on HandleUncaughtErrorHandler {
      log('Error');
    } on ArgumentError {
      log('Error');
    } catch (e) {
      log('Error caught$e');
    }
  }

  static Future cancelNotification() async {
    await _notifications.cancelAll();
  }
}
