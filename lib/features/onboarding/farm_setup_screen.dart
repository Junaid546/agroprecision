import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../data/models/farm_model.dart';
import '../../../data/models/shed_model.dart';

enum SetupStep { farmDetails, firstShed }

class FarmSetupScreen extends ConsumerStatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  ConsumerState<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends ConsumerState<FarmSetupScreen> {
  SetupStep _currentStep = SetupStep.farmDetails;

  // Farm form controllers
  final _farmNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();

  // Shed form controllers
  final _shedNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _areaController = TextEditingController();

  // Form validation
  final _farmFormKey = GlobalKey<FormState>();
  final _shedFormKey = GlobalKey<FormState>();

  // Error messages
  String? _farmNameError;
  String? _ownerNameError;
  String? _shedNameError;
  String? _capacityError;

  bool _isLoading = false;

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
      final uuid = const Uuid();

      // Create farm
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
        shedIds: [], // Will be updated after shed creation
      );

      await ref.read(farmRepositoryProvider).create(farm);

      // Create shed
      final shed = ShedModel.create(
        farmId: farm.id,
        name: _shedNameController.text.trim(),
        capacity: int.parse(_capacityController.text),
        areaSqMeters: _areaController.text.trim().isNotEmpty
            ? double.tryParse(_areaController.text)
            : null,
      );

      await ref.read(shedRepositoryProvider).create(shed);

      // Update farm with shed ID
      final updatedFarm = FarmModel(
        id: farm.id,
        name: farm.name,
        ownerName: farm.ownerName,
        location: farm.location,
        phone: farm.phone,
        createdAt: farm.createdAt,
        updatedAt: DateTime.now(),
        shedIds: [shed.id],
        isSetupComplete: true,
        preferences: farm.preferences,
      );
      await ref.read(farmRepositoryProvider).update(updatedFarm);

      // Update current farm provider
      ref.read(currentFarmProvider.notifier).updateFarm(updatedFarm);

      // Navigate to dashboard
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Step indicator
              Row(
                children: [
                  _buildStepIndicator(
                    step: SetupStep.farmDetails,
                    label: 'Farm Details',
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: AppColors.outlineVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildStepIndicator(
                    step: SetupStep.firstShed,
                    label: 'First Shed',
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: _currentStep == SetupStep.farmDetails
                      ? _buildFarmForm()
                      : _buildShedForm(),
                ),
              ),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _nextStep,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _currentStep == SetupStep.farmDetails
                              ? 'Continue'
                              : 'Complete Setup',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.onPrimary,
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

  Widget _buildStepIndicator({required SetupStep step, required String label}) {
    final isActive = _currentStep == step;
    final isCompleted = step.index < _currentStep.index;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppColors.primaryContainer
                : isActive
                    ? AppColors.primary
                    : AppColors.surfaceContainer,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.outline,
              width: 2,
            ),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : Center(
                  child: Text(
                    '${step.index + 1}',
                    style: AppTypography.labelBold.copyWith(
                      color:
                          isActive ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTypography.labelMd.copyWith(
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Details',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your poultry farm',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 24),

          // Farm Name
          TextFormField(
            controller: _farmNameController,
            decoration: InputDecoration(
              labelText: 'Farm Name',
              hintText: 'Enter your farm name',
              errorText: _farmNameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Owner Name
          TextFormField(
            controller: _ownerNameController,
            decoration: InputDecoration(
              labelText: 'Owner Name',
              hintText: 'Enter owner full name',
              errorText: _ownerNameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Location (optional)
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: 'Location (Optional)',
              hintText: 'City, State or Region',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phone (optional)
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number (Optional)',
              hintText: '+1 (555) 123-4567',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShedForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'First Shed',
            style: AppTypography.headlineMd,
          ),
          const SizedBox(height: 8),
          Text(
            'Set up your first poultry shed',
            style: AppTypography.bodyMd,
          ),
          const SizedBox(height: 24),

          // Shed Name
          TextFormField(
            controller: _shedNameController,
            decoration: InputDecoration(
              labelText: 'Shed Name',
              hintText: 'e.g., Block A, Main Shed',
              errorText: _shedNameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Capacity
          TextFormField(
            controller: _capacityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Capacity',
              hintText: 'Number of birds',
              errorText: _capacityError,
              suffixText: 'birds',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Area (optional)
          TextFormField(
            controller: _areaController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Area (Optional)',
              hintText: 'Area in square meters',
              suffixText: 'm²',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
