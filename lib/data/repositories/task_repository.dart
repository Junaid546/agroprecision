import '../../services/hive_service.dart';
import '../models/task_model.dart';

class TaskRepository {
  Future<TaskModel?> getById(String id) async {
    return HiveService.taskBox.get(id);
  }

  Future<TaskModel> create(TaskModel task) async {
    await HiveService.taskBox.put(task.id, task);
    return task;
  }

  Future<List<TaskModel>> getByDate(DateTime date) async {
    return HiveService.getTasksForDate(date);
  }

  Future<List<TaskModel>> getByBatch(String batchId) async {
    return HiveService.taskBox.values
        .where((t) => t.batchId == batchId)
        .toList()
      ..sort(
          (a, b) => (a.scheduledTime ?? '').compareTo(b.scheduledTime ?? ''));
  }

  Future<List<TaskModel>> getPendingForToday() async {
    final today = DateTime.now();
    return (await getByDate(today))
        .where((t) => t.status == TaskStatus.pending)
        .toList();
  }

  Future<int> getCompletedCountForDate(DateTime date) async {
    return (await getByDate(date))
        .where((t) => t.status == TaskStatus.done)
        .length;
  }

  Future<int> getTotalCountForDate(DateTime date) async {
    return (await getByDate(date)).length;
  }

  Future<TaskModel> markDone(String taskId) async {
    final task = HiveService.taskBox.get(taskId);
    if (task == null) throw Exception('Task not found');
    task.status = TaskStatus.done;
    task.completedAt = DateTime.now();
    await task.save();
    return task;
  }

  Future<TaskModel> markPending(String taskId) async {
    final task = HiveService.taskBox.get(taskId);
    if (task == null) throw Exception('Task not found');
    task.status = TaskStatus.pending;
    task.completedAt = null;
    await task.save();
    return task;
  }

  Future<void> markAllDoneForDate(DateTime date) async {
    final tasks = await getByDate(date);
    for (final task in tasks) {
      if (task.status != TaskStatus.done) {
        task.status = TaskStatus.done;
        task.completedAt = DateTime.now();
        await task.save();
      }
    }
  }

  Future<TaskModel> update(TaskModel task) async {
    await task.save();
    return task;
  }

  Future<void> delete(String id) async {
    await HiveService.taskBox.delete(id);
  }
}
