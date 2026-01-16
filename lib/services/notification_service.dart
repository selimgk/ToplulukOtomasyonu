import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import '../models.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const fln.AndroidInitializationSettings initializationSettingsAndroid =
        fln.AndroidInitializationSettings('@mipmap/ic_launcher');

    const fln.InitializationSettings initializationSettings =
        fln.InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
  }

  Future<void> scheduleEventReminder(Event event) async {
    if (event.id == null) return;

    final scheduledDate = event.date.subtract(const Duration(days: 1));
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      event.id!,
      'Etkinlik Hatırlatması',
      'Yarın "${event.title}" etkinliği var! (${event.location})',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const fln.NotificationDetails(
        android: fln.AndroidNotificationDetails(
          'event_reminders',
          'Etkinlik Hatırlatmaları',
          channelDescription: 'Etkinliklerden 1 gün önce bildirim gönderir.',
          importance: fln.Importance.max,
          priority: fln.Priority.high,
        ),
      ),
      androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
