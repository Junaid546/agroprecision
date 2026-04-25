import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'health_treatment_model.g.dart';

@HiveType(typeId: 14)
enum TreatmentType {
  @HiveField(0)
  vaccination,
  @HiveField(1)
  medication,
  @HiveField(2)
  supportiveCare,
  @HiveField(3)
  disinfection;

  String get displayName => {
        TreatmentType.vaccination: 'Vaccination',
        TreatmentType.medication: 'Medication',
        TreatmentType.supportiveCare: 'Supportive Care',
        TreatmentType.disinfection: 'Disinfection',
      }[this]!;
}

@HiveType(typeId: 18)
class HealthTreatmentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String shedId;

  @HiveField(3)
  String? batchId;

  @HiveField(4)
  TreatmentType type;

  @HiveField(5)
  String title;

  @HiveField(6)
  DateTime scheduledDate;

  @HiveField(7)
  DateTime? completedDate;

  @HiveField(8)
  double? quantityUsed;

  @HiveField(9)
  String? unit;

  @HiveField(10)
  String? inventoryItemId;

  @HiveField(11)
  String? notes;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  bool isCompleted;

  HealthTreatmentModel({
    required this.id,
    required this.farmId,
    required this.shedId,
    this.batchId,
    required this.type,
    required this.title,
    required this.scheduledDate,
    this.completedDate,
    this.quantityUsed,
    this.unit,
    this.inventoryItemId,
    this.notes,
    required this.createdAt,
    this.isCompleted = false,
  });

  factory HealthTreatmentModel.create({
    required String farmId,
    required String shedId,
    String? batchId,
    required TreatmentType type,
    required String title,
    required DateTime scheduledDate,
    double? quantityUsed,
    String? unit,
    String? inventoryItemId,
    String? notes,
  }) {
    return HealthTreatmentModel(
      id: const Uuid().v4(),
      farmId: farmId,
      shedId: shedId,
      batchId: batchId,
      type: type,
      title: title,
      scheduledDate: scheduledDate,
      quantityUsed: quantityUsed,
      unit: unit,
      inventoryItemId: inventoryItemId,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'shedId': shedId,
      'batchId': batchId,
      'type': type.name,
      'title': title,
      'scheduledDate': scheduledDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'quantityUsed': quantityUsed,
      'unit': unit,
      'inventoryItemId': inventoryItemId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory HealthTreatmentModel.fromJson(Map<String, dynamic> json) {
    return HealthTreatmentModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      shedId: json['shedId'] as String,
      batchId: json['batchId'] as String?,
      type: TreatmentType.values.byName(json['type'] as String),
      title: json['title'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      completedDate: json['completedDate'] != null
          ? DateTime.parse(json['completedDate'] as String)
          : null,
      quantityUsed: (json['quantityUsed'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      inventoryItemId: json['inventoryItemId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
