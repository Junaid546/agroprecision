import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../data/models/farm_model.dart';
import '../../../data/models/shed_model.dart';
import '../../../services/notification_service.dart';

enum SetupStep { farmDetails, firstShed }

class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  SetupStep _currentStep = SetupStep.farmDetails;

  final _farmNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  final _shedNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _areaController = TextEditingController();

  String? _farmNameError;
  String? _ownerNameError;
  String? _shedNameError;
  String? _capacityError;

  bool _isLoading = false;
  bool _enableDailyReminder = true; // Default ON
  TimeOfDay _reminderTime = const TimeOfDay(hour: 6, minute: 0);

  @override
  void dispose() {
    _farmNameController.dispose();
    _ownerNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _shedNameController.dispose();
    _capacityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == SetupStep.farmDetails) {
      if (_validateFarmForm()) {
        setState(() {
          _currentStep = SetupStep.firstShed;
        });
      }
    } else {
      _completeSetup();
    }
  }

  bool _validateFarmForm() {
    setState(() {
      _farmNameError = null;
      _ownerNameError = null;
    });

    bool isValid = true;

    if (_farmNameController.text.trim().isEmpty) {
      _farmNameError = 'Farm name is required';
      isValid = false;
    } else if (_farmNameController.text.trim().length < 2) {
      _farmNameError = 'Farm name must be at least 2 characters';
      isValid = false;
    }

    if (_ownerNameController.text.trim().isEmpty) {
      _ownerNameError = 'Owner name is required';
      isValid = false;
    }

    return isValid;
  }

  bool _validateShedForm() {
    setState(() {
      _shedNameError = null;
      _capacityError = null;
    });

    bool isValid = true;

    if (_shedNameController.text.trim().isEmpty) {
      _shedNameError = 'Shed name is required';
      isValid = false;
    }

    if (_capacityController.text.trim().isEmpty) {
      _capacityError = 'Capacity is required';
      isValid = false;
    } else {
      final capacity = int.tryParse(_capacityController.text);
      if (capacity == null || capacity <= 0) {
        _capacityError = 'Capacity must be a positive number';
        isValid = false;
      }
    }

    return isValid;
  }

  Future<void> _completeSetup() async {
    if (!_validateShedForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      const uuid = Uuid();

      final farm = FarmModel(
        id: uuid.v4(),
        name: _farmNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shedIds: [],
      );

      await ref.read(farmRepositoryProvider).create(farm);

      final shed = ShedModel.create(
        farmId: farm.id,
        name: _shedNameController.text.trim(),
        capacity: int.parse(_capacityController.text),
        areaSqMeters: _areaController.text.trim().isNotEmpty
            ? double.tryParse(_areaController.text)
            : null,
      );

      await ref.read(shedRepositoryProvider).create(shed);

      final updatedFarm = farm.copyWith(
        shedIds: [shed.id],
        isSetupComplete: true,
        updatedAt: DateTime.now(),
      );
      await ref.read(farmRepositoryProvider).update(updatedFarm);

      ref.read(currentFarmProvider.notifier).updateFarm(updatedFarm);

      if (_enableDailyReminder) {
        await NotificationService.scheduleDailyFeedReminder(
          farmName: updatedFarm.name,
          time: _reminderTime,
        );
      }

      if (mounted) {
        context.go('/home/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setup failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Setup Your Farm'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep == SetupStep.firstShed
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep = SetupStep.farmDetails;
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Step Indicator
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              // Form Card
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _currentStep == SetupStep.farmDetails
                        ? _buildFarmForm()
                        : _buildShedForm(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _currentStep == SetupStep.farmDetails
                              ? 'Continue'
                              : 'Complete Setup',
                          style: AppTypography.labelBold.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildStepBadge(
            1, 'Farm Details', _currentStep == SetupStep.farmDetails),
        const SizedBox(width: 8),
        const Expanded(
            child: Divider(color: AppColors.outlineVariant, thickness: 2)),
        const SizedBox(width: 8),
        _buildStepBadge(2, 'First Shed', _currentStep == SetupStep.firstShed),
      ],
    );
  }

  Widget _buildStepBadge(int number, String label, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.outlineVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTypography.labelBold.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Farm Details', style: AppTypography.headlineMd),
        const SizedBox(height: 8),
        Text('Basic information about your operation',
            style: AppTypography.bodyMd),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _farmNameController,
          label: 'Farm Name',
          hint: 'e.g. Green Valley Poultry',
          error: _farmNameError,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _ownerNameController,
          label: 'Owner Name',
          hint: 'Full name',
          error: _ownerNameError,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _locationController,
          label: 'Location',
          hint: 'City, Region',
          required: false,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          hint: '+123...',
          keyboardType: TextInputType.phone,
          required: false,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text('Daily Feed Reminder', style: AppTypography.labelBold),
          subtitle: const Text('Get notified daily to feed your flock'),
          value: _enableDailyReminder,
          activeThumbColor: AppColors.primary,
          onChanged: (v) => setState(() => _enableDailyReminder = v),
          contentPadding: EdgeInsets.zero,
        ),
        if (_enableDailyReminder)
          InkWell(
            onTap: _pickReminderTime,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Reminder Time'),
              child: Text(_reminderTime.format(context)),
            ),
          ),
      ],
    );
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Widget _buildShedForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('First Shed', style: AppTypography.headlineMd),
        const SizedBox(height: 8),
        Text('Create your first poultry house', style: AppTypography.bodyMd),
        const SizedBox(height: 32),
        _buildTextField(
          controller: _shedNameController,
          label: 'Shed Name',
          hint: 'e.g. Block A',
          error: _shedNameError,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _capacityController,
          label: 'Capacity (Birds)',
          hint: '0',
          keyboardType: TextInputType.number,
          error: _capacityError,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _areaController,
          label: 'Area (sq meters)',
          hint: '0.0',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          required: false,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTypography.labelBold),
            if (required)
              const Text(' *', style: TextStyle(color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            errorText: error,
            fillColor: AppColors.surfaceContainerLowest,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
          ),
        ),
      ],
    );
  }
}
