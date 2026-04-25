import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/batch_model.dart';
import '../../../data/models/task_model.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../services/notification_service.dart';
import '../providers/batch_providers.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/tasks/providers/task_providers.dart';

class CreateBatchScreen extends ConsumerStatefulWidget {
  const CreateBatchScreen({super.key});

  @override
  ConsumerState<CreateBatchScreen> createState() => _CreateBatchScreenState();
}

class _CreateBatchScreenState extends ConsumerState<CreateBatchScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController batchNumberController;
  late TextEditingController initialCountController;
  late TextEditingController costPerBirdController;
  late TextEditingController breedController;
  late TextEditingController startDateController;
  late TextEditingController targetDaysController;
  late TextEditingController targetWeightController;
  late TextEditingController notesController;

  // State
  String? selectedShedId;
  DateTime? _selectedDate;
  bool isLoading = false;
  bool createFeedTasks = true; // Default ON
  bool createWaterTasks = true; // Default ON
  bool createObservationTasks = true; // Default ON

  @override
  void initState() {
    super.initState();
    _initControllers();
    _autofillBatchNumber();
  }

  void _initControllers() {
    batchNumberController = TextEditingController();
    initialCountController = TextEditingController();
    costPerBirdController = TextEditingController();
    breedController = TextEditingController();
    startDateController = TextEditingController(
      text: DateFormatter.toDisplayDate(DateTime.now()),
    );
    targetDaysController = TextEditingController(text: '42');
    targetWeightController = TextEditingController();
    notesController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  Future<void> _autofillBatchNumber() async {
    final farm = ref.read(currentFarmProvider);
    if (farm == null) return;
    final batches = await ref.read(batchRepositoryProvider).getByFarm(farm.id);
    final nextNum = batches.length + 1;
    batchNumberController.text = 'Batch #${nextNum.toString().padLeft(3, '0')}';
  }

  @override
  void dispose() {
    batchNumberController.dispose();
    initialCountController.dispose();
    costPerBirdController.dispose();
    breedController.dispose();
    startDateController.dispose();
    targetDaysController.dispose();
    targetWeightController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('New Batch', style: AppTypography.headlineMd),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.surfaceContainerHigh, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel('BATCH IDENTITY'),
              const SizedBox(height: 16),
              _buildBatchNumberField(),
              const SizedBox(height: 20),
              _buildShedSelector(),
              const SizedBox(height: 32),
              _buildSectionLabel('FLOCK DETAILS'),
              const SizedBox(height: 16),
              _buildInitialCountField(),
              const SizedBox(height: 20),
              _buildCostPerBirdField(),
              const SizedBox(height: 20),
              _buildBreedField(),
              const SizedBox(height: 32),
              _buildSectionLabel('TIMELINE'),
              const SizedBox(height: 16),
              _buildStartDatePicker(),
              const SizedBox(height: 20),
              _buildTargetDaysField(),
              const SizedBox(height: 20),
              _buildTargetWeightField(),
              const SizedBox(height: 32),
              _buildSectionLabel('AUTO-GENERATE TASKS'),
              const SizedBox(height: 16),
              _buildAutoTasksCard(),
              const SizedBox(height: 32),
              _buildSectionLabel('NOTES (OPTIONAL)'),
              const SizedBox(height: 16),
              _buildNotesField(),
              const SizedBox(height: 100), // Space for fixed button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTypography.labelBold.copyWith(
        color: AppColors.primary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBatchNumberField() {
    return TextFormField(
      controller: batchNumberController,
      decoration: _inputDecoration(
        'Batch Number',
        Icons.tag_rounded,
        'e.g. Batch #204',
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Batch number is required' : null,
    );
  }

  Widget _buildShedSelector() {
    final shedsAsync = ref.watch(shedListProvider);

    return shedsAsync.when(
      loading: () => Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      error: (e, _) => Text(
        "Could not load sheds. Check settings.",
        style: AppTypography.bodyMd.copyWith(color: AppColors.error),
      ),
      data: (sheds) {
        if (sheds.isEmpty) {
          return _buildNoShedsWarning();
        }
        return DropdownButtonFormField<String>(
          initialValue: selectedShedId,
          decoration: _inputDecoration(
              'Select Shed', Icons.warehouse_outlined, 'Choose a shed...'),
          items: sheds
              .map((shed) => DropdownMenuItem(
                    value: shed.id,
                    child: Text(
                      '${shed.name} (${NumberFormat("#,###").format(shed.capacity)} birds)',
                      style: AppTypography.bodyLg,
                    ),
                  ))
              .toList(),
          onChanged: (val) => setState(() => selectedShedId = val),
          validator: (v) => v == null ? 'Please select a shed' : null,
        );
      },
    );
  }

  Widget _buildNoShedsWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No Sheds Found',
                    style: AppTypography.bodyLg.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.error)),
                const Text(
                    'Go to Settings â†’ Shed Management to add a shed first.',
                    style: TextStyle(color: AppColors.onErrorContainer)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/home/settings/sheds'),
            child: const Text('Go',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialCountField() {
    return TextFormField(
      controller: initialCountController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration(
          'Initial Bird Count', Icons.pets_rounded, 'e.g. 5000'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Bird count is required';
        final n = int.tryParse(v.trim());
        if (n == null || n <= 0) return 'Enter a valid number greater than 0';
        if (n > 100000) return 'Value seems too high. Max 100,000';
        return null;
      },
    );
  }

  Widget _buildCostPerBirdField() {
    return TextFormField(
      controller: costPerBirdController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      decoration: _inputDecoration('Purchase Cost Per Bird (\$)',
          Icons.attach_money_rounded, 'e.g. 0.85'),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Cost per bird is required';
        final n = double.tryParse(v.trim());
        if (n == null || n <= 0) return 'Enter a valid cost';
        return null;
      },
    );
  }

  Widget _buildBreedField() {
    return TextFormField(
      controller: breedController,
      decoration: _inputDecoration('Breed (Optional)', Icons.biotech_outlined,
          'e.g. Ross 308, Cobb 500'),
    );
  }

  Widget _buildStartDatePicker() {
    return TextFormField(
      controller: startDateController,
      readOnly: true,
      onTap: _pickDate,
      decoration:
          _inputDecoration('Start Date', Icons.calendar_today_rounded, '')
              .copyWith(
        suffixIcon: const Icon(Icons.edit_calendar_outlined,
            color: AppColors.onSurfaceVariant, size: 20),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? 'Start date is required' : null,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        startDateController.text = DateFormatter.toDisplayDate(picked);
      });
    }
  }

  Widget _buildTargetDaysField() {
    return TextFormField(
      controller: targetDaysController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: _inputDecoration('Target Days to Harvest (Optional)',
              Icons.schedule_rounded, 'e.g. 42')
          .copyWith(
        helperText: "Industry standard: 35â€“42 days for broilers",
      ),
    );
  }

  Widget _buildTargetWeightField() {
    return TextFormField(
      controller: targetWeightController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _inputDecoration('Target Weight at Harvest (kg, Optional)',
          Icons.scale_outlined, 'e.g. 2.5'),
    );
  }

  Widget _buildAutoTasksCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Automatic Daily Tasks",
                        style: AppTypography.bodyLg
                            .copyWith(fontWeight: FontWeight.bold)),
                    const Text(
                        "Poultry Path will create recurring daily tasks for this batch.",
                        style: TextStyle(
                            color: AppColors.onSurfaceVariant, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 12),
          _AutoTaskToggle(
            icon: Icons.grass_rounded,
            iconColor: AppColors.primary,
            label: "Morning Feed (06:00 daily)",
            value: createFeedTasks,
            onChanged: (v) => setState(() => createFeedTasks = v),
          ),
          _AutoTaskToggle(
            icon: Icons.water_drop_outlined,
            iconColor: const Color(0xFF1565C0),
            label: "Water Check (07:30 daily)",
            value: createWaterTasks,
            onChanged: (v) => setState(() => createWaterTasks = v),
          ),
          _AutoTaskToggle(
            icon: Icons.visibility_outlined,
            iconColor: AppColors.secondary,
            label: "Evening Observation (18:00 daily)",
            value: createObservationTasks,
            onChanged: (v) => setState(() => createObservationTasks = v),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.surfaceContainerHigh),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.vaccines_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Vaccination reminders will be auto-scheduled:",
                    style: AppTypography.bodyMd
                        .copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _VaccinationRow("Day 7", "Newcastle Disease (1st dose)"),
          const _VaccinationRow("Day 14", "Gumboro / IBD Vaccine"),
          const _VaccinationRow("Day 21", "Newcastle Disease (2nd dose)"),
          const _VaccinationRow("Day 28", "Fowl Typhoid Vaccine"),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: notesController,
      maxLines: 3,
      decoration: _inputDecoration('Notes (Optional)', Icons.notes,
          'Any special instructions for this batch...'),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: const Border(
            top: BorderSide(color: AppColors.surfaceContainerHigh)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  _handleSave();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('Create Batch',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      final farm = ref.read(currentFarmProvider);
      if (farm == null) {
        _showError('No farm found. Please complete setup first.');
        return;
      }

      final int initialCount = int.parse(initialCountController.text.trim());
      final double costPerBird =
          double.parse(costPerBirdController.text.trim());
      final String batchId = const Uuid().v4();
      final DateTime startDate = _selectedDate ?? DateTime.now();

      final batch = BatchModel(
        id: batchId,
        shedId: selectedShedId!,
        farmId: farm.id,
        batchNumber: batchNumberController.text.trim(),
        initialCount: initialCount,
        initialCostPerBird: costPerBird,
        startDate: startDate,
        endDate: null,
        status: BatchStatus.active,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        breed: breedController.text.trim().isEmpty
            ? null
            : breedController.text.trim(),
        targetWeightKg: targetWeightController.text.trim().isEmpty
            ? null
            : double.tryParse(targetWeightController.text.trim()),
        targetDays: targetDaysController.text.trim().isEmpty
            ? null
            : int.tryParse(targetDaysController.text.trim()),
      );

      await ref.read(batchRepositoryProvider).create(batch);
      await ref
          .read(shedRepositoryProvider)
          .assignBatch(selectedShedId!, batchId);
      await _generateDailyTasks(batchId, farm.id, startDate);
      await _scheduleVaccinationAlerts(batchId, batch.batchNumber, startDate);

      await ref.read(allBatchesProvider.notifier).refresh();
      ref.invalidate(activeBatchesProvider);
      ref.invalidate(dashboardSummaryProvider);
      ref.invalidate(shedListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('${batch.batchNumber} created successfully!'),
              ],
            ),
            backgroundColor: AppColors.primaryContainer,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        context.pop();
        context.push('/home/batches/$batchId');
      }
    } catch (e) {
      _showError('Failed to create batch: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _generateDailyTasks(
      String batchId, String farmId, DateTime startDate) async {
    final taskRepo = ref.read(taskRepositoryProvider);
    final int totalDays = int.tryParse(targetDaysController.text) ?? 42;

    List<Future> taskFutures = [];

    for (int i = 0; i < totalDays; i++) {
      final taskDate = startDate.add(Duration(days: i));

      if (createFeedTasks) {
        final feedTask = TaskModel(
          id: const Uuid().v4(),
          farmId: farmId,
          batchId: batchId,
          title: 'Morning Feed Distribution',
          description: 'Distribute morning feed ration',
          priority: TaskPriority.routine,
          status: TaskStatus.pending,
          scheduledDate: taskDate,
          scheduledTime: '06:00',
          isRecurring: true,
          recurringPattern: 'daily',
          createdAt: DateTime.now(),
          shedId: selectedShedId,
        );

        if (i < 7) {
          final timeParts = feedTask.scheduledTime!.split(':');
          final scheduledDateTime = DateTime(
            taskDate.year,
            taskDate.month,
            taskDate.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
          );

          if (scheduledDateTime.isAfter(DateTime.now())) {
            final notifId = await NotificationService.scheduleTaskNotification(
              taskId: feedTask.id,
              title: feedTask.title,
              body:
                  'Time for morning feed distribution for ${batchNumberController.text}',
              scheduledDateTime: scheduledDateTime,
              priority: TaskPriority.routine,
            );
            feedTask.notificationId = notifId;
          }
        }
        taskFutures.add(taskRepo.create(feedTask));
      }

      if (createWaterTasks) {
        taskFutures.add(taskRepo.create(TaskModel(
          id: const Uuid().v4(),
          farmId: farmId,
          batchId: batchId,
          title: 'Water System Check',
          description: 'Check water levels and nipple drinkers',
          priority: TaskPriority.routine,
          status: TaskStatus.pending,
          scheduledDate: taskDate,
          scheduledTime: '07:30',
          isRecurring: true,
          recurringPattern: 'daily',
          createdAt: DateTime.now(),
          shedId: selectedShedId,
        )));
      }

      if (createObservationTasks) {
        taskFutures.add(taskRepo.create(TaskModel(
          id: const Uuid().v4(),
          farmId: farmId,
          batchId: batchId,
          title: 'Evening Flock Observation',
          description:
              'Check bird behavior, feeding activity, and any signs of illness',
          priority: TaskPriority.routine,
          status: TaskStatus.pending,
          scheduledDate: taskDate,
          scheduledTime: '18:00',
          isRecurring: true,
          recurringPattern: 'daily',
          createdAt: DateTime.now(),
          shedId: selectedShedId,
        )));
      }
    }

    await Future.wait(taskFutures);
    ref.invalidate(tasksForDateProvider);
    ref.invalidate(taskProgressProvider);
  }

  Future<void> _scheduleVaccinationAlerts(
      String batchId, String batchName, DateTime startDate) async {
    final vaccinations = [
      {'day': 7, 'name': 'Newcastle Disease (1st dose)'},
      {'day': 14, 'name': 'Gumboro (IBD) Vaccine'},
      {'day': 21, 'name': 'Newcastle Disease (2nd dose)'},
      {'day': 28, 'name': 'Fowl Pox Vaccine'},
    ];

    final farmId = ref.read(currentFarmProvider)!.id;

    for (final vax in vaccinations) {
      final day = vax['day'] as int;
      final name = vax['name'] as String;
      final vaxDate = startDate.add(Duration(days: day - 1));

      // We also create a task for it
      final vaxTask = TaskModel(
        id: const Uuid().v4(),
        farmId: farmId,
        batchId: batchId,
        title: 'Vaccination: $name',
        description: '$batchName â€” Day $day vaccination due today',
        priority: TaskPriority.priority,
        status: TaskStatus.pending,
        scheduledDate: vaxDate,
        scheduledTime: '09:00',
        isRecurring: false,
        createdAt: DateTime.now(),
        shedId: selectedShedId,
      );

      // Schedule the actual notification
      await NotificationService.scheduleVaccinationAlert(
        batchId: batchId,
        batchName: batchName,
        dayNumber: day,
        batchStartDate: startDate,
        vaccineName: name,
      );

      await ref.read(taskRepositoryProvider).create(vaxTask);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  InputDecoration _inputDecoration(
      String label, IconData prefixIcon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _AutoTaskToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AutoTaskToggle({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTypography.bodyMd)),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _VaccinationRow extends StatelessWidget {
  final String day;
  final String vaccine;

  const _VaccinationRow(this.day, this.vaccine);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text("$day â€” $vaccine",
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
