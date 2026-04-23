import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'batch_model.g.dart';

@HiveType(typeId: 8)
enum BatchStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  cancelled,
}

@HiveType(typeId: 2)
class BatchModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String shedId;

  @HiveField(2)
  String farmId;

  @HiveField(3)
  String batchNumber;

  @HiveField(4)
  int initialCount;

  @HiveField(5)
  double initialCostPerBird;

  @HiveField(6)
  DateTime startDate;

  @HiveField(7)
  DateTime? endDate;

  @HiveField(8)
  BatchStatus status;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  DateTime updatedAt;

  @HiveField(12)
  String? breed;

  @HiveField(13)
  double? targetWeightKg;

  @HiveField(14)
  int? targetDays;

  BatchModel({
    required this.id,
    required this.shedId,
    required this.farmId,
    required this.batchNumber,
    required this.initialCount,
    required this.initialCostPerBird,
    required this.startDate,
    this.endDate,
    this.status = BatchStatus.active,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.breed,
    this.targetWeightKg,
    this.targetDays,
  });

  factory BatchModel.create({
    required String shedId,
    required String farmId,
    required String batchNumber,
    required int initialCount,
    required double initialCostPerBird,
    required DateTime startDate,
    String? breed,
    double? targetWeightKg,
    int? targetDays,
    String? notes,
  }) {
    final now = DateTime.now();
    return BatchModel(
      id: const Uuid().v4(),
      shedId: shedId,
      farmId: farmId,
      batchNumber: batchNumber,
      initialCount: initialCount,
      initialCostPerBird: initialCostPerBird,
      startDate: startDate,
      createdAt: now,
      updatedAt: now,
      breed: breed,
      targetWeightKg: targetWeightKg,
      targetDays: targetDays,
      notes: notes,
    );
  }

  // Computed properties
  int get ageInDays => DateTime.now().difference(startDate).inDays;
  String get displayName => batchNumber;
  bool get isActive => status == BatchStatus.active;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shedId': shedId,
      'farmId': farmId,
      'batchNumber': batchNumber,
      'initialCount': initialCount,
      'initialCostPerBird': initialCostPerBird,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'breed': breed,
      'targetWeightKg': targetWeightKg,
      'targetDays': targetDays,
    };
  }

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json['id'],
      shedId: json['shedId'],
      farmId: json['farmId'],
      batchNumber: json['batchNumber'],
      initialCount: json['initialCount'],
      initialCostPerBird: (json['initialCostPerBird'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: BatchStatus.values.byName(json['status']),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      breed: json['breed'],
      targetWeightKg: json['targetWeightKg'] != null ? (json['targetWeightKg'] as num).toDouble() : null,
      targetDays: json['targetDays'],
    );
  }
}
