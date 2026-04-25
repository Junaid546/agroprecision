import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/seed_data.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../../batch/providers/batch_providers.dart';
import '../../../shared/providers/notification_providers.dart';
import '../../shed_control/providers/shed_control_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shedsAsync = ref.watch(shedListProvider);

    return Scaffold(
      appBar: const AgroAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: AppTypography.headlineLg),
            Text(
              'Manage your farm operations and preferences.',
              style: AppTypography.bodyMd
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'FARM PROFILE',
              rows: [
                _SettingRow(
                  icon: Icons.business,
                  iconBg: AppColors.surfaceContainerLow,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'General Details',
                  subtitle: 'Name, location, and contact info',
                  onTap: () => context.push('/home/settings/farm-profile'),
                ),
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  iconBg: AppColors.surfaceContainerLow,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Alert Preferences',
                  subtitle: ref.watch(pendingNotificationsProvider).when(
                        data: (list) =>
                            '${list.length} active reminders scheduled',
                        loading: () => 'Loading reminders...',
                        error: (_, __) => 'Email, SMS, and push notifications',
                      ),
                  onTap: () => context.push('/home/settings/alert-preferences'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            shedsAsync.when(
              data: (sheds) => _SettingsSection(
                title: 'SHED MANAGEMENT',
                rows: [
                  ...sheds.map((shed) => _SettingRow(
                        icon: Icons.warehouse,
                        iconBg: const Color(0xFFFFF3E0),
                        iconColor: AppColors.secondary,
                        title: '${shed.name} Configurations',
                        subtitle: 'Climate targets, readings, and shed control',
                        onTap: () =>
                            context.push('/home/settings/sheds/${shed.id}/control'),
                      )),
                  _SettingRow(
                    icon: Icons.add,
                    iconBg: AppColors.surfaceContainerLow,
                    iconColor: AppColors.primary,
                    title: 'Add New Shed',
                    subtitle: 'Register a new poultry house',
                    onTap: () => context.push('/home/settings/sheds'),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Text('Error loading sheds: $e'),
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'OPERATIONS',
              rows: [
                _SettingRow(
                  icon: Icons.inventory_2_outlined,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: AppColors.primary,
                  title: 'Inventory',
                  subtitle: ref.watch(lowStockItemsProvider).when(
                        data: (items) => items.isEmpty
                            ? 'Feed, medicine, vaccine, and supply stock'
                            : '${items.length} item(s) below reorder level',
                        loading: () => 'Loading inventory...',
                        error: (_, __) => 'Feed, medicine, vaccine, and supply stock',
                      ),
                  onTap: () => context.push('/home/settings/inventory'),
                ),
                _SettingRow(
                  icon: Icons.vaccines_outlined,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  title: 'Health & Treatments',
                  subtitle: 'Vaccination, medication, and shed care records',
                  onTap: () => context.push('/home/settings/health'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'ACCESS & SECURITY',
              rows: [
                _SettingRow(
                  icon: Icons.group,
                  iconBg: AppColors.surfaceContainerLow,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'User Permissions',
                  subtitle: 'Manage staff roles and access',
                  onTap: () => context.push('/home/settings/staff'),
                ),
                _SettingRow(
                  icon: Icons.security,
                  iconBg: AppColors.surfaceContainerLow,
                  iconColor: AppColors.onSurfaceVariant,
                  title: 'Security Settings',
                  subtitle: 'Local PIN lock and access protection',
                  onTap: () => context.push('/home/settings/security'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SettingsSection(
              title: 'DATA & SYSTEM',
              rows: [
                _SettingRow(
                  icon: Icons.download,
                  iconBg: const Color(0xFFE8F5E9),
                  iconColor: AppColors.primary,
                  title: 'Data Export',
                  subtitle: 'Download reports and historical data',
                  onTap: () => context.push('/home/settings/data-export'),
                ),
                _SettingRow(
                  icon: Icons.cloud_upload,
                  iconBg: const Color(0xFFE3F2FD),
                  iconColor: const Color(0xFF1565C0),
                  title: 'System Backup',
                  subtitle: 'Manage automated backups',
                  onTap: () => context.push('/home/settings/backup'),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;

  const _SettingsSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelBold.copyWith(
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyLg),
                      Text(subtitle, style: AppTypography.bodyMd),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppColors.outline, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
