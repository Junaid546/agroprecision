import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/widgets/agro_app_bar.dart';

class FarmProfileScreen extends ConsumerStatefulWidget {
  const FarmProfileScreen({super.key});

  @override
  ConsumerState<FarmProfileScreen> createState() => _FarmProfileScreenState();
}

class _FarmProfileScreenState extends ConsumerState<FarmProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ownerController;
  late TextEditingController _locationController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    final farm = ref.read(currentFarmProvider);
    _nameController = TextEditingController(text: farm?.name ?? '');
    _ownerController = TextEditingController(text: farm?.ownerName ?? '');
    _locationController = TextEditingController(text: farm?.location ?? '');
    _contactController = TextEditingController(text: farm?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ownerController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final currentFarm = ref.read(currentFarmProvider);
    if (currentFarm == null) return;

    final updatedFarm = currentFarm.copyWith(
      name: _nameController.text,
      ownerName: _ownerController.text,
      location: _locationController.text,
      phone: _contactController.text,
      updatedAt: DateTime.now(),
    );

    await ref.read(currentFarmProvider.notifier).updateFarm(updatedFarm);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Farm profile updated!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farm Profile', style: AppTypography.headlineLg),
              Text(
                'Manage your farm details and contact info.',
                style: AppTypography.bodyMd
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Farm Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ownerController,
                decoration: const InputDecoration(labelText: 'Owner Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                decoration:
                    const InputDecoration(labelText: 'Contact Information'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
