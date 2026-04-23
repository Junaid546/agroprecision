import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'shed_model.g.dart';

@HiveType(typeId: 1)
class ShedModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String name;

  @HiveField(3)
  int capacity;

  @HiveField(4)
  double? areaSqMeters;

  @HiveField(5)
  String? activeBatchId;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isActive;

  ShedModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.capacity,
    this.areaSqMeters,
    this.activeBatchId,
    required this.createdAt,
    this.notes,
    this.isActive = true,
  });

  factory ShedModel.create({
    required String farmId,
    required String name,
    required int capacity,
    double? areaSqMeters,
    String? notes,
  }) {
    return ShedModel(
      id: const Uuid().v4(),
      farmId: farmId,
      name: name,
      capacity: capacity,
      areaSqMeters: areaSqMeters,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'capacity': capacity,
      'areaSqMeters': areaSqMeters,
      'activeBatchId': activeBatchId,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
    };
  }

  factory ShedModel.fromJson(Map<String, dynamic> json) {
    return ShedModel(
      id: json['id'],
      farmId: json['farmId'],
      name: json['name'],
      capacity: json['capacity'],
      areaSqMeters: json['areaSqMeters'] != null ? (json['areaSqMeters'] as num).toDouble() : null,
      activeBatchId: json['activeBatchId'],
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
    );
  }
}
