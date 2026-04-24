import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../shared/providers/repository_providers.dart';

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
        await _repo.markDone(taskId);
      } else {
        await _repo.markPending(taskId);
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
      await _repo.create(task);
      _ref.invalidate(tasksForDateProvider);
      _ref.invalidate(taskProgressProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
