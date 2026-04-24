import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../services/notification_service.dart';

// Selected date for task screen (default today)
final taskSelectedDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

// Tasks for selected date
final tasksForDateProvider = FutureProvider<List<TaskModel>>((ref) async {
  final date = ref.watch(taskSelectedDateProvider);
  return ref.watch(taskRepositoryProvider).getByDate(date);
});

// Task completion progress
final taskProgressProvider = FutureProvider<TaskProgress>((ref) async {
  final date = ref.watch(taskSelectedDateProvider);
  final repo = ref.watch(taskRepositoryProvider);
  final completed = await repo.getCompletedCountForDate(date);
  final total = await repo.getTotalCountForDate(date);
  return TaskProgress(completed: completed, total: total);
});

class TaskProgress {
  final int completed;
  final int total;
  double get percentage => total > 0 ? completed / total : 0.0;
  String get label => '$completed/$total';
  TaskProgress({required this.completed, required this.total});
}

// Task action notifier
final taskActionProvider =
    StateNotifierProvider<TaskActionNotifier, AsyncValue<void>>((ref) {
  return TaskActionNotifier(ref.watch(taskRepositoryProvider), ref);
});

class TaskActionNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repo;
  final Ref _ref;
  TaskActionNotifier(this._repo, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> toggleTask(String taskId, bool isDone) async {
    state = const AsyncValue.loading();
    try {
      if (isDone) {
        final task = await _repo.markDone(taskId);
        if (task.notificationId != null) {
          await NotificationService.cancelNotification(task.notificationId!);
        }
      } else {
        final task = await _repo.markPending(taskId);
        // Reschedule if it's in the future?
        // For simplicity, we just toggle. But marking pending might need rescheduling.
      }
      _ref.invalidate(tasksForDateProvider);
      _ref.invalidate(taskProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllDone(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _repo.getByDate(date);
      for (final task in tasks) {
        if (task.status == TaskStatus.pending && task.notificationId != null) {
          await NotificationService.cancelNotification(task.notificationId!);
        }
      }
      await _repo.markAllDoneForDate(date);
      _ref.invalidate(tasksForDateProvider);
      _ref.invalidate(taskProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createTask(TaskModel task) async {
    state = const AsyncValue.loading();
    try {
      if (task.scheduledTime != null && task.status == TaskStatus.pending) {
        final scheduledDate = task.scheduledDate;
        final timeParts = task.scheduledTime!.split(':');
        final scheduledDateTime = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        if (scheduledDateTime.isAfter(DateTime.now())) {
          final notifId = await NotificationService.scheduleTaskNotification(
            taskId: task.id,
            title: task.title,
            body: task.description ?? 'Task Reminder',
            scheduledDateTime: scheduledDateTime,
            priority: task.priority,
          );
          task.notificationId = notifId;
        }
      }
      await _repo.create(task);
      _ref.invalidate(tasksForDateProvider);
      _ref.invalidate(taskProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    state = const AsyncValue.loading();
    try {
      final task = await _repo.getById(taskId);
      if (task != null && task.notificationId != null) {
        await NotificationService.cancelNotification(task.notificationId!);
      }
      await _repo.delete(taskId);
      _ref.invalidate(tasksForDateProvider);
      _ref.invalidate(taskProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
