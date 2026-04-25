import 'package:agro_precision/data/models/batch_model.dart';
import 'package:agro_precision/data/models/health_treatment_model.dart';
import 'package:agro_precision/data/models/inventory_item_model.dart';
import 'package:agro_precision/data/models/shed_environment_reading_model.dart';
import 'package:agro_precision/data/models/shed_model.dart';
import 'package:agro_precision/data/repositories/health_treatment_repository.dart';
import 'package:agro_precision/data/repositories/inventory_repository.dart';
import 'package:agro_precision/data/repositories/shed_environment_repository.dart';
import 'package:agro_precision/data/repositories/shed_repository.dart';
import 'package:agro_precision/services/shed_operations_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockShedRepository extends Mock implements ShedRepository {}

class MockShedEnvironmentRepository extends Mock
    implements ShedEnvironmentRepository {}

class MockInventoryRepository extends Mock implements InventoryRepository {}

class MockHealthTreatmentRepository extends Mock
    implements HealthTreatmentRepository {}

void main() {
  late ShedOperationsService service;
  late MockShedRepository shedRepository;
  late MockShedEnvironmentRepository environmentRepository;
  late MockInventoryRepository inventoryRepository;
  late MockHealthTreatmentRepository healthTreatmentRepository;

  setUp(() {
    shedRepository = MockShedRepository();
    environmentRepository = MockShedEnvironmentRepository();
    inventoryRepository = MockInventoryRepository();
    healthTreatmentRepository = MockHealthTreatmentRepository();

    service = ShedOperationsService(
      shedRepository: shedRepository,
      environmentRepository: environmentRepository,
      inventoryRepository: inventoryRepository,
      healthTreatmentRepository: healthTreatmentRepository,
    );
  });

  test('buildSnapshot creates environment and stock alerts from shed state',
      () async {
    final shed = ShedModel.create(
      farmId: 'farm-1',
      name: 'Shed A',
      capacity: 5000,
    );

    final reading = ShedEnvironmentReadingModel.create(
      farmId: shed.farmId,
      shedId: shed.id,
      recordedAt: DateTime.now(),
      temperatureC: 35,
      humidityPercent: 80,
      ammoniaPpm: 25,
      co2Ppm: 4200,
      feedBinLevelPercent: 10,
      waterLevelPercent: 15,
    );

    final lowStockItem = InventoryItemModel.create(
      farmId: shed.farmId,
      name: 'Starter Feed',
      category: InventoryCategory.feed,
      quantity: 10,
      unit: 'kg',
      reorderLevel: 25,
      shedId: shed.id,
    );

    final openTreatment = HealthTreatmentModel.create(
      farmId: shed.farmId,
      shedId: shed.id,
      type: TreatmentType.medication,
      title: 'Respiratory support',
      scheduledDate: DateTime.now(),
    );

    final doneTreatment = HealthTreatmentModel.create(
      farmId: shed.farmId,
      shedId: shed.id,
      type: TreatmentType.vaccination,
      title: 'Routine vaccine',
      scheduledDate: DateTime.now(),
    )..isCompleted = true;

    when(() => environmentRepository.getLatest(shed.id))
        .thenAnswer((_) async => reading);
    when(() => inventoryRepository.getByFarm(shed.farmId))
        .thenAnswer((_) async => [lowStockItem]);
    when(() => healthTreatmentRepository.getByShed(shed.id))
        .thenAnswer((_) async => [openTreatment, doneTreatment]);

    final snapshot = await service.buildSnapshot(shed);

    expect(snapshot.latestReading, reading);
    expect(snapshot.lowStockItems, hasLength(1));
    expect(snapshot.treatmentCount, 1);
    expect(
      snapshot.alerts.map((alert) => alert.title),
      containsAll(<String>[
        'Environment Alert',
        'Humidity Alert',
        'Ammonia Alert',
        'CO2 Alert',
        'Feed Bin Low',
        'Water Level Low',
        'Stock Reorder Needed',
      ]),
    );
  });

  test('getControlProfile falls back to age-based defaults', () async {
    final batch = BatchModel.create(
      farmId: 'farm-1',
      shedId: 'shed-1',
      batchNumber: 'B-100',
      initialCount: 1000,
      initialCostPerBird: 1.0,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    final shed = ShedModel.create(
      farmId: 'farm-1',
      name: 'Shed B',
      capacity: 3000,
    );

    final profile = await service.getControlProfile(
      shed,
      activeBatch: batch,
    );

    expect(profile.targetTempMinC, 21);
    expect(profile.targetTempMaxC, 26);
    expect(profile.ventilationMode, 'Tunnel');
    expect(profile.coolingMode, 'Auto');
  });
}
