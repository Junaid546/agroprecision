import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/task_model.dart';
import 'hive_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // SCHEDULE A TASK NOTIFICATION
  static Future<int> scheduleTaskNotification({
    required String taskId,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    required TaskPriority priority,
  }) async {
    final int notifId = taskId.hashCode.abs() % 100000;

    // 15 minutes before scheduled time
    final notifTime = scheduledDateTime.subtract(const Duration(minutes: 15));

    if (notifTime.isBefore(DateTime.now())) return notifId; // Already past

    final tzDateTime = tz.TZDateTime.from(notifTime, tz.local);

    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Farm Tasks',
      channelDescription: 'Reminders for scheduled farm tasks',
      importance:
          priority == TaskPriority.priority || priority == TaskPriority.critical
              ? Importance.high
              : Importance.defaultImportance,
      priority:
          priority == TaskPriority.priority || priority == TaskPriority.critical
              ? Priority.high
              : Priority.defaultPriority,
      color: const Color(0xFF003B1B),
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'default.aiff',
    );

    NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      notifId,
      '🌾 $title',
      body,
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );

    return notifId;
  }

  // SCHEDULE VACCINATION ALERT (specific batch day)
  static Future<void> scheduleVaccinationAlert({
    required String batchId,
    required String batchName,
    required int dayNumber,
    required DateTime batchStartDate,
    required String vaccineName,
  }) async {
    final vaccinationDate = batchStartDate.add(Duration(days: dayNumber - 1));
    final notifTime = DateTime(
      vaccinationDate.year,
      vaccinationDate.month,
      vaccinationDate.day,
      7,
      0,
    );

    if (notifTime.isBefore(DateTime.now())) return;

    await scheduleTaskNotification(
      taskId: '${batchId}_vaccine_$dayNumber',
      title: 'Vaccination Due: $vaccineName',
      body: '$batchName — Day $dayNumber vaccination is due today',
      scheduledDateTime: notifTime,
      priority: TaskPriority.priority,
    );
  }

  // CANCEL A NOTIFICATION
  static Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // CANCEL ALL NOTIFICATIONS FOR A BATCH
  static Future<void> cancelAllForBatch(String batchId) async {
    final tasks = HiveService.getTasksForBatch(batchId);
    for (final task in tasks) {
      if (task.notificationId != null) {
        await cancelNotification(task.notificationId!);
      }
    }
  }

  // DAILY FEED REMINDER
  static Future<void> scheduleDailyFeedReminder({
    required String farmName,
    required TimeOfDay time,
  }) async {
    final int id = 'daily_feed'.hashCode.abs();

    final now = DateTime.now();
    var scheduledDate =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      '🌾 Morning Feed Reminder',
      'Time to distribute morning feed for $farmName',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Daily Reminders',
          importance: Importance.defaultImportance,
          color: Color(0xFF003B1B),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents:
          DateTimeComponents.time, // Repeats daily at same time
    );
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Navigate to tasks screen when notification tapped
    // This usually requires a global navigator key or a deep link
  }

  // LIST ALL PENDING NOTIFICATIONS (for settings screen display)
  static Future<List<PendingNotificationRequest>>
      getPendingNotifications() async {
    return await _plugin.pendingNotificationRequests();
  }
}
