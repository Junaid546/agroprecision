import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/shed_control_profile.dart';
import '../../../data/models/shed_environment_reading_model.dart';
import '../../../data/models/shed_model.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../services/notification_service.dart';
import '../../../services/shed_operations_service.dart';
import '../../../shared/providers/app_state_provider.dart';
import '../../../shared/providers/farm_preferences_provider.dart';
import '../../../shared/providers/repository_providers.dart';
import '../../../shared/widgets/agro_app_bar.dart';
import '../providers/shed_control_providers.dart';

class ShedControlScreen extends ConsumerWidget {
  final String shedId;

  const ShedControlScreen({super.key, required this.shedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shedAsync = ref.watch(shedDetailsProvider(shedId));
    final snapshotAsync = ref.watch(shedOperationsSnapshotProvider(shedId));
    final readingsAsync = ref.watch(shedEnvironmentReadingsProvider(shedId));

    return shedAsync.when(
      loading: () => const Scaffold(
        appBar: AgroAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: const AgroAppBar(),
        body: Center(child: Text('Error loading shed: $error')),
      ),
      data: (shed) {
        if (shed == null) {
          return const Scaffold(
            appBar: AgroAppBar(),
            body: Center(child: Text('Shed not found')),
          );
        }

        return Scaffold(
          appBar: const AgroAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shed.name, style: AppTypography.headlineLg),
                Text(
                  'Software-first shed control with environment checks, targets, and stock-aware operations.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showLogReadingSheet(context, shed),
                      icon: const Icon(Icons.thermostat_outlined),
                      label: const Text('Log Reading'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showEditTargetsSheet(context, shed),
                      icon: const Icon(Icons.tune),
                      label: const Text('Edit Targets'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/home/settings/inventory'),
                      icon: const Icon(Icons.inventory_2_outlined),
                      label: const Text('Inventory'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/home/settings/health'),
                      icon: const Icon(Icons.vaccines_outlined),
                      label: const Text('Treatments'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                snapshotAsync.when(
                  data: (snapshot) => _SnapshotCard(snapshot: snapshot),
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text('Error loading shed operations: $error'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                readingsAsync.when(
                  data: (readings) => _ReadingsCard(readings: readings),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogReadingSheet(BuildContext context, ShedModel shed) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LogReadingSheet(shed: shed),
    );
  }

  void _showEditTargetsSheet(BuildContext context, ShedModel shed) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditTargetsSheet(shed: shed),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final ShedOperationsSnapshot snapshot;

  const _SnapshotCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final latest = snapshot.latestReading;
    final profile = snapshot.profile;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Shed Status', style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            if (latest == null)
              const Text('No environment reading recorded yet.')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricChip(
                    label: 'Temp',
                    value: '${latest.temperatureC.toStringAsFixed(1)} C',
                  ),
                  _MetricChip(
                    label: 'Humidity',
                    value: '${latest.humidityPercent.toStringAsFixed(0)}%',
                  ),
                  _MetricChip(
                    label: 'NH3',
                    value:
                        '${latest.ammoniaPpm?.toStringAsFixed(1) ?? '--'} ppm',
                  ),
                  _MetricChip(
                    label: 'CO2',
                    value: '${latest.co2Ppm?.toStringAsFixed(0) ?? '--'} ppm',
                  ),
                  _MetricChip(
                    label: 'Feed Bin',
                    value:
                        '${latest.feedBinLevelPercent?.toStringAsFixed(0) ?? '--'}%',
                  ),
                  _MetricChip(
                    label: 'Water',
                    value:
                        '${latest.waterLevelPercent?.toStringAsFixed(0) ?? '--'}%',
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Text(
              'Targets: ${profile.targetTempMinC.toStringAsFixed(1)}-${profile.targetTempMaxC.toStringAsFixed(1)} C | '
              '${profile.humidityMinPercent.toStringAsFixed(0)}-${profile.humidityMaxPercent.toStringAsFixed(0)}% RH',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: 12),
            Text(
              'Modes: ${profile.ventilationMode} ventilation | ${profile.heatingMode} heating | ${profile.coolingMode} cooling | ${profile.lightingMode} lighting',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            if (snapshot.alerts.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...snapshot.alerts.take(3).map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${alert.title}: ${alert.message}'),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadingsCard extends StatelessWidget {
  final List<ShedEnvironmentReadingModel> readings;

  const _ReadingsCard({required this.readings});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Readings', style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            if (readings.isEmpty)
              const Text('No readings logged yet.')
            else
              ...readings.take(5).map(
                    (reading) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${reading.temperatureC.toStringAsFixed(1)} C | ${reading.humidityPercent.toStringAsFixed(0)}% RH',
                      ),
                      subtitle: Text(
                        '${reading.recordedAt.toLocal()}'
                            .split('.')
                            .first
                            .replaceFirst('T', ' '),
                      ),
                      trailing: Text(
                        'NH3 ${reading.ammoniaPpm?.toStringAsFixed(1) ?? '--'}',
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTypography.labelMd),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.bodyLg),
        ],
      ),
    );
  }
}

class _LogReadingSheet extends ConsumerStatefulWidget {
  final ShedModel shed;

  const _LogReadingSheet({required this.shed});

  @override
  ConsumerState<_LogReadingSheet> createState() => _LogReadingSheetState();
}

class _LogReadingSheetState extends ConsumerState<_LogReadingSheet> {
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _co2Controller = TextEditingController();
  final _feedBinController = TextEditingController();
  final _waterController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _tempController.dispose();
    _humidityController.dispose();
    _ammoniaController.dispose();
    _co2Controller.dispose();
    _feedBinController.dispose();
    _waterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Environment Reading', style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            _buildField(_tempController, 'Temperature (C)'),
            const SizedBox(height: 12),
            _buildField(_humidityController, 'Humidity (%)'),
            const SizedBox(height: 12),
            _buildField(_ammoniaController, 'Ammonia (ppm)'),
            const SizedBox(height: 12),
            _buildField(_co2Controller, 'CO2 (ppm)'),
            const SizedBox(height: 12),
            _buildField(_feedBinController, 'Feed Bin Level (%)'),
            const SizedBox(height: 12),
            _buildField(_waterController, 'Water Level (%)'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Reading'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _save() async {
    final farm = ref.read(currentFarmProvider);
    final temperature = double.tryParse(_tempController.text);
    final humidity = double.tryParse(_humidityController.text);
    if (farm == null || temperature == null || humidity == null) {
      return;
    }

    final reading = ShedEnvironmentReadingModel.create(
      farmId: farm.id,
      shedId: widget.shed.id,
      recordedAt: DateTime.now(),
      temperatureC: temperature,
      humidityPercent: humidity,
      ammoniaPpm: double.tryParse(_ammoniaController.text),
      co2Ppm: double.tryParse(_co2Controller.text),
      feedBinLevelPercent: double.tryParse(_feedBinController.text),
      waterLevelPercent: double.tryParse(_waterController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    await ref.read(shedEnvironmentRepositoryProvider).create(reading);
    ref.invalidate(shedEnvironmentReadingsProvider(widget.shed.id));
    ref.invalidate(shedOperationsSnapshotProvider(widget.shed.id));
    ref.invalidate(dashboardSummaryProvider);

    final preferences = ref.read(farmPreferencesProvider);
    final snapshot = await ref
        .read(shedOperationsServiceProvider)
        .buildSnapshot(widget.shed);
    if (preferences.pushNotifications && snapshot.alerts.isNotEmpty) {
      final alert = snapshot.alerts.first;
      await NotificationService.showImmediateAlert(
        title: alert.title,
        body: alert.message,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _EditTargetsSheet extends ConsumerStatefulWidget {
  final ShedModel shed;

  const _EditTargetsSheet({required this.shed});

  @override
  ConsumerState<_EditTargetsSheet> createState() => _EditTargetsSheetState();
}

class _EditTargetsSheetState extends ConsumerState<_EditTargetsSheet> {
  late final TextEditingController _minTempController;
  late final TextEditingController _maxTempController;
  late final TextEditingController _minHumidityController;
  late final TextEditingController _maxHumidityController;
  late final TextEditingController _ammoniaController;
  late final TextEditingController _co2Controller;
  late final TextEditingController _feedLowController;
  late final TextEditingController _waterLowController;
  late final ShedControlProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = ShedControlProfile.fromMap(widget.shed.controlProfile);
    _minTempController =
        TextEditingController(text: _profile.targetTempMinC.toString());
    _maxTempController =
        TextEditingController(text: _profile.targetTempMaxC.toString());
    _minHumidityController =
        TextEditingController(text: _profile.humidityMinPercent.toString());
    _maxHumidityController =
        TextEditingController(text: _profile.humidityMaxPercent.toString());
    _ammoniaController =
        TextEditingController(text: _profile.ammoniaMaxPpm.toString());
    _co2Controller = TextEditingController(text: _profile.co2MaxPpm.toString());
    _feedLowController =
        TextEditingController(text: _profile.feedBinLowPercent.toString());
    _waterLowController =
        TextEditingController(text: _profile.waterLowPercent.toString());
  }

  @override
  void dispose() {
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHumidityController.dispose();
    _maxHumidityController.dispose();
    _ammoniaController.dispose();
    _co2Controller.dispose();
    _feedLowController.dispose();
    _waterLowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Shed Targets', style: AppTypography.headlineMd),
            const SizedBox(height: 16),
            _buildField(_minTempController, 'Min Temp C'),
            const SizedBox(height: 12),
            _buildField(_maxTempController, 'Max Temp C'),
            const SizedBox(height: 12),
            _buildField(_minHumidityController, 'Min Humidity %'),
            const SizedBox(height: 12),
            _buildField(_maxHumidityController, 'Max Humidity %'),
            const SizedBox(height: 12),
            _buildField(_ammoniaController, 'Ammonia Max ppm'),
            const SizedBox(height: 12),
            _buildField(_co2Controller, 'CO2 Max ppm'),
            const SizedBox(height: 12),
            _buildField(_feedLowController, 'Feed Low %'),
            const SizedBox(height: 12),
            _buildField(_waterLowController, 'Water Low %'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Targets'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _save() async {
    final updatedProfile = _profile.copyWith(
      targetTempMinC: double.tryParse(_minTempController.text),
      targetTempMaxC: double.tryParse(_maxTempController.text),
      humidityMinPercent: double.tryParse(_minHumidityController.text),
      humidityMaxPercent: double.tryParse(_maxHumidityController.text),
      ammoniaMaxPpm: double.tryParse(_ammoniaController.text),
      co2MaxPpm: double.tryParse(_co2Controller.text),
      feedBinLowPercent: double.tryParse(_feedLowController.text),
      waterLowPercent: double.tryParse(_waterLowController.text),
    );

    await ref
        .read(shedOperationsServiceProvider)
        .saveControlProfile(widget.shed, updatedProfile);
    ref.invalidate(shedDetailsProvider(widget.shed.id));
    ref.invalidate(shedOperationsSnapshotProvider(widget.shed.id));
    ref.invalidate(dashboardSummaryProvider);

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
