import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotification {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future init() async {
    try {
      _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/todo_icon');
      final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
        onDidReceiveLocalNotification: (id, title, body, payload) {},
      );
      final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(defaultActionName: 'Open notification');
      final InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux);
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) => {},
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notifications: $e');
      }
    }
  }

  static Future showSimpleNotification({
    required int id,
    required String title,
    required String body,
    required String chanId,
    required String payload,
  }) async {
    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          chanId, 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails, payload: payload);
    } catch (e) {
      if (kDebugMode) {
        print('Error showing simple notification: $e');
      }
    }
  }

  static Future cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling notification: $e');
      }
    }
  }

  static Future showHourlyNotification({
    required int id,
    required String title,
    required String body,
    required String chanId,
  }) async {
    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          chanId, 'repeating channel name',
          channelDescription: 'repeating description',
          importance: Importance.max,
          priority: Priority.high);
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.hourly,
        notificationDetails,
        payload: 'item x',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing hourly notification: $e');
      }
    }
  }

  static Future showDailyNotification({
    required int id,
    required String title,
    required String body,
    required String chanId,
  }) async {
    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          chanId, 'repeating channel name',
          channelDescription: 'repeating description',
          importance: Importance.max,
          priority: Priority.high);
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        notificationDetails,
        payload: 'item x',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing daily notification: $e');
      }
    }
  }

  static Future<void> showMinutelyNotification({
    required int id,
    required String title,
    required String body,
    required String chanId,
  }) async {
    try {
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          chanId, 'repeating channel name',
          channelDescription: 'repeating description',
          importance: Importance.max,
          priority: Priority.high);
      NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.everyMinute,
        notificationDetails,
        payload: 'item x',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error showing minutely notification: $e');
      }
    }
  }

  static Future<bool> isNotificationScheduled(int id) async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      return pendingNotifications.any((element) => element.id == id);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if notification is scheduled: $e');
      }
      return false;
    }
  }

  static Future<void> requestExactAlarmPermission() async {
    try {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting exact alarm permission: $e');
      }
    }
  }

  static Future<bool> isExactAlarmPermissionGranted() async {
    try {
      return await Permission.scheduleExactAlarm.isGranted;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking exact alarm permission: $e');
      }
      return false;
    }
  }

  static Future<void> handleTodoDeletionNotifications(String todoId, String todoTitle) async {
    try {
      int notificationId = ('${todoId}hourly'.substring(0,4)).hashCode;
      if (await LocalNotification.isNotificationScheduled(notificationId)) {
        await LocalNotification.cancelNotification(notificationId);
      }
      notificationId = ('${todoId}daily'.substring(0,4)).hashCode;
      if (await LocalNotification.isNotificationScheduled(notificationId)) {
        await LocalNotification.cancelNotification(notificationId);
      }
      notificationId = ('${todoId}minutely'.substring(0,4)).hashCode;
      if (await LocalNotification.isNotificationScheduled(notificationId)) {
        await LocalNotification.cancelNotification(notificationId);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling todo deletion notifications: $e');
      }
    } finally {
      await LocalNotification.showSimpleNotification(
        id: 0,
        title: 'Todo $todoTitle deleted',
        body: 'Todo $todoTitle has been deleted',
        chanId: 'todo_offline',
        payload: 'item x deleted',
      );
    }
  }
}