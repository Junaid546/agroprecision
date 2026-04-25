import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'inventory_transaction_model.g.dart';

@HiveType(typeId: 13)
enum InventoryTransactionType {
  @HiveField(0)
  restock,
  @HiveField(1)
  usage,
  @HiveField(2)
  adjustment,
  @HiveField(3)
  treatment;

  String get displayName => {
        InventoryTransactionType.restock: 'Restock',
        InventoryTransactionType.usage: 'Usage',
        InventoryTransactionType.adjustment: 'Adjustment',
        InventoryTransactionType.treatment: 'Treatment',
      }[this]!;
}

@HiveType(typeId: 17)
class InventoryTransactionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String itemId;

  @HiveField(3)
  InventoryTransactionType type;

  @HiveField(4)
  double quantityChange;

  @HiveField(5)
  String unit;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? batchId;

  @HiveField(9)
  String? shedId;

  @HiveField(10)
  String? notes;

  InventoryTransactionModel({
    required this.id,
    required this.farmId,
    required this.itemId,
    required this.type,
    required this.quantityChange,
    required this.unit,
    required this.date,
    required this.createdAt,
    this.batchId,
    this.shedId,
    this.notes,
  });

  factory InventoryTransactionModel.create({
    required String farmId,
    required String itemId,
    required InventoryTransactionType type,
    required double quantityChange,
    required String unit,
    required DateTime date,
    String? batchId,
    String? shedId,
    String? notes,
  }) {
    return InventoryTransactionModel(
      id: const Uuid().v4(),
      farmId: farmId,
      itemId: itemId,
      type: type,
      quantityChange: quantityChange,
      unit: unit,
      date: date,
      createdAt: DateTime.now(),
      batchId: batchId,
      shedId: shedId,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'itemId': itemId,
      'type': type.name,
      'quantityChange': quantityChange,
      'unit': unit,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'batchId': batchId,
      'shedId': shedId,
      'notes': notes,
    };
  }

  factory InventoryTransactionModel.fromJson(Map<String, dynamic> json) {
    return InventoryTransactionModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      itemId: json['itemId'] as String,
      type: InventoryTransactionType.values.byName(json['type'] as String),
      quantityChange: (json['quantityChange'] as num).toDouble(),
      unit: json['unit'] as String,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      batchId: json['batchId'] as String?,
      shedId: json['shedId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
