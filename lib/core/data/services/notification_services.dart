import 'dart:developer';

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
      // await Permission.scheduleExactAlarm.isDenied.then((value) {
      //   if (!value) {
      //     Permission.scheduleExactAlarm.request();
      //   }
      // });
      _notifications.zonedSchedule(
        id,
        title,
        body,
        // tz.TZDateTime.from(
        //   scheduledTime,
        //   tz.local,
        // ),
        _nextInstanceOfTenAM(selectedTime: scheduledTime),
        await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      log('Error caught$e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTenAM({required DateTime selectedTime}) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      selectedTime.year,
      selectedTime.month,
      selectedTime.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future cancelNotification() async {
    await _notifications.cancelAll();
  }
}
