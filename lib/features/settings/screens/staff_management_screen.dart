import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/staff_member_model.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';

final staffMembersProvider = FutureProvider<List<StaffMemberModel>>((ref) async {
  final farm = ref.watch(currentFarmProvider);
  if (farm == null) {
    return [];
  }
  return ref.read(staffRepositoryProvider).getByFarm(farm.id);
});

class StaffManagementScreen extends ConsumerWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farm = ref.watch(currentFarmProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: farm == null ? null : () => _showAddDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        label: const Text('Add Staff'),
        icon: const Icon(Icons.person_add_alt_1),
      ),
      body: farm == null
          ? const Center(child: Text('Create a farm before adding staff'))
          : ref.watch(staffMembersProvider).when(
                data: (staff) => ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text('User Permissions', style: AppTypography.headlineLg),
                    Text(
                      'Manage local staff roles without removing any existing owner workflows.',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (staff.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No staff members added yet.'),
                        ),
                      )
                    else
                      ...staff.map(
                        (member) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: SwitchListTile(
                            title: Text(member.name),
                            subtitle: Text(
                              '${member.role}${member.phone != null ? ' | ${member.phone}' : ''}',
                            ),
                            value: member.isActive,
                            onChanged: (value) async {
                              member.isActive = value;
                              await ref
                                  .read(staffRepositoryProvider)
                                  .update(member);
                              ref.invalidate(staffMembersProvider);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) =>
                    Center(child: Text('Error loading staff: $error')),
              ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final farm = ref.read(currentFarmProvider);
    if (farm == null) {
      return;
    }

    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Staff Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: roleController,
              decoration: const InputDecoration(
                labelText: 'Role (Owner/Supervisor)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  roleController.text.trim().isEmpty) {
                return;
              }

              final member = StaffMemberModel.create(
                farmId: farm.id,
                name: nameController.text.trim(),
                role: roleController.text.trim(),
                phone: phoneController.text.trim().isEmpty
                    ? null
                    : phoneController.text.trim(),
              );
              await ref.read(staffRepositoryProvider).create(member);
              ref.invalidate(staffMembersProvider);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
