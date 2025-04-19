import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> showTimeNotification(String title, String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'time_reminder_channel',
          'Time Reminder Notifications',
          channelDescription: 'Notifications for time reminders',
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      0, // Notification ID
      title,
      message,
      platformDetails,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
