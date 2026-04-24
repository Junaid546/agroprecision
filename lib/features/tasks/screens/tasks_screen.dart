import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/status_chip.dart';
import '../providers/task_providers.dart';
import '../../batch/providers/batch_providers.dart';
import '../../../services/notification_service.dart';
import 'package:intl/intl.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(taskSelectedDateProvider);
    final farm = ref.watch(currentFarmProvider);
    final tasksAsync = ref.watch(tasksForDateProvider);
    final progressAsync = ref.watch(taskProgressProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(ref, selectedDate, farm?.name ?? 'Unknown Farm', progressAsync),
            const SizedBox(height: 8),
            _buildProgressBar(progressAsync),
            const SizedBox(height: 20),
            _buildTasksCard(ref, tasksAsync, selectedDate),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context, ref, selectedDate),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref, DateTime selectedDate, String farmName, AsyncValue<TaskProgress> progressAsync) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Schedule', style: AppTypography.headlineLg),
              Text(
                '${DateFormatter.toFullDate(selectedDate)} • $farmName',
                style: AppTypography.bodyMd,
              ),
            ],
          ),
        ),
        progressAsync.when(
          data: (progress) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.done_all, color: AppColors.inversePrimary, size: 16),
                const SizedBox(width: 6),
                Text(
                  progress.label,
                  style: AppTypography.labelBold.copyWith(color: AppColors.inversePrimary),
                ),
              ],
            ),
          ),
          loading: () => const SizedBox(width: 60, height: 32),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildProgressBar(AsyncValue<TaskProgress> progressAsync) {
    return progressAsync.when(
      data: (progress) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress.percentage,
          backgroundColor: AppColors.surfaceContainerHigh,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 6,
        ),
      ),
      loading: () => const LinearProgressIndicator(minHeight: 6),
      error: (_, __) => const SizedBox(),
    );
  }

  Widget _buildTasksCard(WidgetRef ref, AsyncValue<List<TaskModel>> tasksAsync, DateTime selectedDate) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Text('Pending Tasks', style: AppTypography.headlineMd),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(taskActionProvider.notifier).markAllDone(selectedDate),
                  child: Text('Select All', style: AppTypography.bodyMd.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const Divider(),
          tasksAsync.when(
            data: (tasks) {
              if (tasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: EmptyState(
                    message: 'All tasks completed for today!',
                    icon: Icons.check_circle_outline,
                  ),
                );
              }
              return Column(
                children: [
                  for (final task in tasks) ...[
                    _TaskRow(task: task),
                    const Divider(),
                  ],
                ],
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            error: (e, __) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context, WidgetRef ref, DateTime initialDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTaskBottomSheet(initialDate: initialDate),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  final TaskModel task;
  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: isDone ? AppColors.surfaceContainerLowest : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => ref.read(taskActionProvider.notifier).toggleTask(task.id, !isDone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primaryContainer : Colors.transparent,
                border: !isDone ? Border.all(color: AppColors.outline, width: 1.5) : null,
                borderRadius: BorderRadius.circular(6),
              ),
              child: isDone ? const Icon(Icons.check, color: AppColors.inversePrimary, size: 16) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: isDone
                      ? AppTypography.bodyLg.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.outline,
                        )
                      : AppTypography.bodyLg,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(task.scheduledTime ?? '', style: AppTypography.labelMd),
                    if (task.shedId != null) ...[
                      const Text(' • ', style: AppTypography.labelMd),
                      const Icon(Icons.warehouse_outlined, size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 2),
                      FutureBuilder(
                        future: _getShedName(ref, task.shedId!),
                        builder: (context, snapshot) => Text(snapshot.data ?? '...', style: AppTypography.labelMd),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(
            label: isDone ? 'DONE' : task.priority.displayLabel,
            status: isDone
                ? ChipStatus.done
                : (task.priority == TaskPriority.critical
                    ? ChipStatus.critical
                    : (task.priority == TaskPriority.priority ? ChipStatus.priority : ChipStatus.routine)),
          ),
        ],
      ),
    );
  }

  Future<String> _getShedName(WidgetRef ref, String shedId) async {
    final sheds = await ref.read(shedListProvider.future);
    return sheds.firstWhere((s) => s.id == shedId, orElse: () => throw Exception()).name;
  }
}

class _AddTaskBottomSheet extends ConsumerStatefulWidget {
  final DateTime initialDate;
  const _AddTaskBottomSheet({required this.initialDate});

  @override
  ConsumerState<_AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<_AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  TaskPriority _priority = TaskPriority.routine;
  String? _selectedBatchId;
  String? _selectedShedId;
  bool _isRecurring = false;
  String? _recurringPattern;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(activeBatchesProvider);
    final shedsAsync = ref.watch(shedListProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Task', style: AppTypography.headlineMd),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'e.g., Afternoon Feeding',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(DateFormatter.toDisplayDate(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(_selectedTime?.format(context) ?? 'Set Time'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Priority', style: AppTypography.labelBold),
              const SizedBox(height: 8),
              Row(
                children: TaskPriority.values.map((p) {
                  final isSelected = _priority == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.displayLabel),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _priority = p),
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              batchesAsync.when(
                data: (batches) => DropdownButtonFormField<String>(
                  value: _selectedBatchId,
                  decoration: const InputDecoration(labelText: 'Link to Batch (Optional)'),
                  items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (v) => setState(() => _selectedBatchId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),
              shedsAsync.when(
                data: (sheds) => DropdownButtonFormField<String>(
                  value: _selectedShedId,
                  decoration: const InputDecoration(labelText: 'Shed (Optional)'),
                  items: sheds.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                  onChanged: (v) => setState(() => _selectedShedId = v),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Recurring Task'),
                value: _isRecurring,
                onChanged: (v) => setState(() => _isRecurring = v),
                contentPadding: EdgeInsets.zero,
              ),
              if (_isRecurring)
                DropdownButtonFormField<String>(
                  value: _recurringPattern,
                  decoration: const InputDecoration(labelText: 'Pattern'),
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  ],
                  onChanged: (v) => setState(() => _recurringPattern = v),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final farm = ref.read(currentFarmProvider);
    if (farm == null) return;

    final timeStr = _selectedTime != null
        ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final task = TaskModel.create(
      farmId: farm.id,
      title: _titleController.text,
      scheduledDate: _selectedDate,
      scheduledTime: timeStr,
      priority: _priority,
      batchId: _selectedBatchId,
      shedId: _selectedShedId,
      isRecurring: _isRecurring,
      recurringPattern: _recurringPattern,
    );

    await ref.read(taskActionProvider.notifier).createTask(task);
    if (mounted) Navigator.pop(context);
  }
}
