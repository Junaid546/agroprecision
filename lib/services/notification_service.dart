import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/task_model.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future<int> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required TaskPriority priority,
  }) async {
    final id = taskId.hashCode;
    final android = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      importance: priority == TaskPriority.priority ? Importance.max : Importance.defaultImportance,
      priority: priority == TaskPriority.priority ? Priority.high : Priority.defaultPriority,
    );
    const ios = DarwinNotificationDetails();
    final details = NotificationDetails(android: android, iOS: ios);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDateTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
    return id;
  }

  static Future<void> scheduleVaccinationAlert({
    required String batchId,
    required String batchName,
    required int dayNumber,
    required DateTime batchStartDate,
    required String vaccineName,
  }) async {
    final scheduledDate = batchStartDate.add(Duration(days: dayNumber - 1));
    final notificationDate = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      9, 0,
    );

    if (notificationDate.isBefore(DateTime.now())) return;

    await scheduleTaskNotification(
      taskId: 'vax_${batchId}_$dayNumber',
      title: 'Vaccination Alert: $batchName',
      body: 'Today is Day $dayNumber. Vaccine due: $vaccineName',
      scheduledDateTime: notificationDate,
      priority: TaskPriority.priority,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
