import '../data/models/batch_model.dart';
import '../data/models/inventory_item_model.dart';
import '../data/models/shed_control_profile.dart';
import '../data/models/shed_environment_reading_model.dart';
import '../data/models/shed_model.dart';
import '../data/repositories/health_treatment_repository.dart';
import '../data/repositories/inventory_repository.dart';
import '../data/repositories/shed_environment_repository.dart';
import '../data/repositories/shed_repository.dart';
import 'calculation_engine.dart';

class ShedOperationsSnapshot {
  final ShedModel shed;
  final ShedEnvironmentReadingModel? latestReading;
  final ShedControlProfile profile;
  final List<ActionAlert> alerts;
  final List<InventoryItemModel> lowStockItems;
  final int treatmentCount;

  const ShedOperationsSnapshot({
    required this.shed,
    required this.latestReading,
    required this.profile,
    required this.alerts,
    required this.lowStockItems,
    required this.treatmentCount,
  });
}

class ShedOperationsService {
  final ShedRepository shedRepository;
  final ShedEnvironmentRepository environmentRepository;
  final InventoryRepository inventoryRepository;
  final HealthTreatmentRepository healthTreatmentRepository;

  ShedOperationsService({
    required this.shedRepository,
    required this.environmentRepository,
    required this.inventoryRepository,
    required this.healthTreatmentRepository,
  });

  Future<ShedControlProfile> getControlProfile(
    ShedModel shed, {
    BatchModel? activeBatch,
  }) async {
    return ShedControlProfile.fromMap(
      shed.controlProfile,
      ageDays: activeBatch?.ageInDays ?? 1,
    );
  }

  Future<ShedModel> saveControlProfile(
    ShedModel shed,
    ShedControlProfile profile,
  ) async {
    final updated = shed.copyWith(
      controlProfile: profile.toMap(),
      updatedAt: DateTime.now(),
    );
    return shedRepository.update(updated);
  }

  Future<ShedOperationsSnapshot> buildSnapshot(
    ShedModel shed, {
    BatchModel? activeBatch,
  }) async {
    final profile = await getControlProfile(shed, activeBatch: activeBatch);
    final latestReading = await environmentRepository.getLatest(shed.id);
    final lowStockItems = (await inventoryRepository.getByFarm(shed.farmId))
        .where(
          (item) =>
              item.isLowStock && (item.shedId == null || item.shedId == shed.id),
        )
        .toList();
    final treatments = await healthTreatmentRepository.getByShed(shed.id);

    return ShedOperationsSnapshot(
      shed: shed,
      latestReading: latestReading,
      profile: profile,
      alerts: _buildAlerts(
        latestReading: latestReading,
        profile: profile,
        lowStockItems: lowStockItems,
      ),
      lowStockItems: lowStockItems,
      treatmentCount: treatments.where((item) => !item.isCompleted).length,
    );
  }

  List<ActionAlert> _buildAlerts({
    required ShedEnvironmentReadingModel? latestReading,
    required ShedControlProfile profile,
    required List<InventoryItemModel> lowStockItems,
  }) {
    final alerts = <ActionAlert>[];

    if (latestReading != null) {
      if (latestReading.temperatureC < profile.targetTempMinC ||
          latestReading.temperatureC > profile.targetTempMaxC) {
        alerts.add(
          ActionAlert(
            type: AlertType.warning,
            title: 'Environment Alert',
            message:
                'Temperature is ${latestReading.temperatureC.toStringAsFixed(1)} C. Target is ${profile.targetTempMinC.toStringAsFixed(1)}-${profile.targetTempMaxC.toStringAsFixed(1)} C.',
            metric: 'environment',
          ),
        );
      }

      if (latestReading.humidityPercent < profile.humidityMinPercent ||
          latestReading.humidityPercent > profile.humidityMaxPercent) {
        alerts.add(
          ActionAlert(
            type: AlertType.warning,
            title: 'Humidity Alert',
            message:
                'Humidity is ${latestReading.humidityPercent.toStringAsFixed(0)}%. Review ventilation or cooling.',
            metric: 'environment',
          ),
        );
      }

      if ((latestReading.ammoniaPpm ?? 0) > profile.ammoniaMaxPpm) {
        alerts.add(
          ActionAlert(
            type: AlertType.danger,
            title: 'Ammonia Alert',
            message:
                'Ammonia is ${latestReading.ammoniaPpm?.toStringAsFixed(1) ?? '--'} ppm.',
            metric: 'environment',
          ),
        );
      }

      if ((latestReading.co2Ppm ?? 0) > profile.co2MaxPpm) {
        alerts.add(
          ActionAlert(
            type: AlertType.warning,
            title: 'CO2 Alert',
            message:
                'CO2 is ${latestReading.co2Ppm?.toStringAsFixed(0) ?? '--'} ppm.',
            metric: 'environment',
          ),
        );
      }

      if ((latestReading.feedBinLevelPercent ?? 100) <
          profile.feedBinLowPercent) {
        alerts.add(
          ActionAlert(
            type: AlertType.warning,
            title: 'Feed Bin Low',
            message:
                'Feed bin is at ${(latestReading.feedBinLevelPercent ?? 0).toStringAsFixed(0)}%.',
            metric: 'stock',
          ),
        );
      }

      if ((latestReading.waterLevelPercent ?? 100) < profile.waterLowPercent) {
        alerts.add(
          ActionAlert(
            type: AlertType.warning,
            title: 'Water Level Low',
            message:
                'Water storage is at ${(latestReading.waterLevelPercent ?? 0).toStringAsFixed(0)}%.',
            metric: 'stock',
          ),
        );
      }
    }

    if (lowStockItems.isNotEmpty) {
      alerts.add(
        ActionAlert(
          type: AlertType.warning,
          title: 'Stock Reorder Needed',
          message:
              '${lowStockItems.length} inventory item(s) are below reorder level.',
          metric: 'stock',
        ),
      );
    }

    return alerts;
  }
}
