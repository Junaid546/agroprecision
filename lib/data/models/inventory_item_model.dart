import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'inventory_item_model.g.dart';

@HiveType(typeId: 12)
enum InventoryCategory {
  @HiveField(0)
  feed,
  @HiveField(1)
  vaccine,
  @HiveField(2)
  medicine,
  @HiveField(3)
  disinfectant,
  @HiveField(4)
  litter,
  @HiveField(5)
  other;

  String get displayName => {
        InventoryCategory.feed: 'Feed',
        InventoryCategory.vaccine: 'Vaccine',
        InventoryCategory.medicine: 'Medicine',
        InventoryCategory.disinfectant: 'Disinfectant',
        InventoryCategory.litter: 'Litter',
        InventoryCategory.other: 'Other',
      }[this]!;
}

@HiveType(typeId: 16)
class InventoryItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String name;

  @HiveField(3)
  InventoryCategory category;

  @HiveField(4)
  double quantity;

  @HiveField(5)
  String unit;

  @HiveField(6)
  double reorderLevel;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime updatedAt;

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  String? shedId;

  @HiveField(11)
  String? notes;

  InventoryItemModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.shedId,
    this.notes,
  });

  factory InventoryItemModel.create({
    required String farmId,
    required String name,
    required InventoryCategory category,
    required double quantity,
    required String unit,
    required double reorderLevel,
    String? shedId,
    String? notes,
  }) {
    final now = DateTime.now();
    return InventoryItemModel(
      id: const Uuid().v4(),
      farmId: farmId,
      name: name,
      category: category,
      quantity: quantity,
      unit: unit,
      reorderLevel: reorderLevel,
      createdAt: now,
      updatedAt: now,
      shedId: shedId,
      notes: notes,
    );
  }

  bool get isLowStock => quantity <= reorderLevel;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'unit': unit,
      'reorderLevel': reorderLevel,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'shedId': shedId,
      'notes': notes,
    };
  }

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      name: json['name'] as String,
      category: InventoryCategory.values.byName(json['category'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      reorderLevel: (json['reorderLevel'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(
          (json['updatedAt'] ?? json['createdAt']) as String),
      isActive: json['isActive'] as bool? ?? true,
      shedId: json['shedId'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
