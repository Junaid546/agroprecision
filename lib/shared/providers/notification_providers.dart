import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final pendingNotificationsProvider = FutureProvider<List<PendingNotificationRequest>>((ref) async {
  return await NotificationService.getPendingNotifications();
});
