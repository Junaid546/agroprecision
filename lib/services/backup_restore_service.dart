import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../data/models/batch_model.dart';
import '../data/models/expense_model.dart';
import '../data/models/farm_model.dart';
import '../data/models/growth_model.dart';
import '../data/models/health_treatment_model.dart';
import '../data/models/inventory_item_model.dart';
import '../data/models/inventory_transaction_model.dart';
import '../data/models/mortality_model.dart';
import '../data/models/sale_model.dart';
import '../data/models/shed_environment_reading_model.dart';
import '../data/models/shed_model.dart';
import '../data/models/staff_member_model.dart';
import '../data/models/task_model.dart';
import 'hive_service.dart';

class BackupRestoreService {
  Future<File> exportBackupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/agro_precision_backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonEncode(HiveService.exportToJson()));
    return file;
  }

  Future<Map<String, dynamic>> readBackupFile(File file) async {
    final content = await file.readAsString();
    return Map<String, dynamic>.from(jsonDecode(content) as Map);
  }

  Future<void> restoreFromFile(File file) async {
    final json = await readBackupFile(file);
    await restoreFromJson(json);
  }

  Future<void> restoreFromJson(Map<String, dynamic> json) async {
    await Future.wait([
      HiveService.farmBox.clear(),
      HiveService.shedBox.clear(),
      HiveService.batchBox.clear(),
      HiveService.expenseBox.clear(),
      HiveService.mortalityBox.clear(),
      HiveService.growthBox.clear(),
      HiveService.saleBox.clear(),
      HiveService.taskBox.clear(),
      HiveService.environmentBox.clear(),
      HiveService.inventoryBox.clear(),
      HiveService.inventoryTransactionBox.clear(),
      HiveService.treatmentBox.clear(),
      HiveService.staffBox.clear(),
    ]);

    await _restoreCollection<FarmModel>(
      collection: json['farms'],
      mapper: (item) => FarmModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.farmBox.put(item.id, item),
    );
    await _restoreCollection<ShedModel>(
      collection: json['sheds'],
      mapper: (item) => ShedModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.shedBox.put(item.id, item),
    );
    await _restoreCollection<BatchModel>(
      collection: json['batches'],
      mapper: (item) => BatchModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.batchBox.put(item.id, item),
    );
    await _restoreCollection<ExpenseModel>(
      collection: json['expenses'],
      mapper: (item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.expenseBox.put(item.id, item),
    );
    await _restoreCollection<MortalityModel>(
      collection: json['mortality'],
      mapper: (item) =>
          MortalityModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.mortalityBox.put(item.id, item),
    );
    await _restoreCollection<GrowthModel>(
      collection: json['growth'],
      mapper: (item) => GrowthModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.growthBox.put(item.id, item),
    );
    await _restoreCollection<SaleModel>(
      collection: json['sales'],
      mapper: (item) => SaleModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.saleBox.put(item.id, item),
    );
    await _restoreCollection<TaskModel>(
      collection: json['tasks'],
      mapper: (item) => TaskModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.taskBox.put(item.id, item),
    );
    await _restoreCollection<ShedEnvironmentReadingModel>(
      collection: json['environmentReadings'],
      mapper: (item) => ShedEnvironmentReadingModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
      writer: (item) => HiveService.environmentBox.put(item.id, item),
    );
    await _restoreCollection<InventoryItemModel>(
      collection: json['inventoryItems'],
      mapper: (item) =>
          InventoryItemModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.inventoryBox.put(item.id, item),
    );
    await _restoreCollection<InventoryTransactionModel>(
      collection: json['inventoryTransactions'],
      mapper: (item) => InventoryTransactionModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
      writer: (item) => HiveService.inventoryTransactionBox.put(item.id, item),
    );
    await _restoreCollection<HealthTreatmentModel>(
      collection: json['healthTreatments'],
      mapper: (item) =>
          HealthTreatmentModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.treatmentBox.put(item.id, item),
    );
    await _restoreCollection<StaffMemberModel>(
      collection: json['staffMembers'],
      mapper: (item) =>
          StaffMemberModel.fromJson(Map<String, dynamic>.from(item)),
      writer: (item) => HiveService.staffBox.put(item.id, item),
    );
  }

  Future<void> _restoreCollection<T>({
    required dynamic collection,
    required T Function(dynamic item) mapper,
    required Future<void> Function(T item) writer,
  }) async {
    if (collection is! List) {
      return;
    }

    for (final rawItem in collection) {
      final item = mapper(rawItem);
      await writer(item);
    }
  }
}
