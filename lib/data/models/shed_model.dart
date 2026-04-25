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

  @HiveField(9)
  Map<String, dynamic>? controlProfile;

  @HiveField(10)
  DateTime? updatedAt;

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
    this.controlProfile,
    this.updatedAt,
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
      updatedAt: DateTime.now(),
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
      'controlProfile': controlProfile,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ShedModel.fromJson(Map<String, dynamic> json) {
    return ShedModel(
      id: json['id'],
      name: json['name'],
      farmId: json['farmId'],
      capacity: json['capacity'],
      areaSqMeters: json['areaSqMeters'] != null
          ? (json['areaSqMeters'] as num).toDouble()
          : null,
      activeBatchId: json['activeBatchId'],
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      controlProfile: json['controlProfile'] != null
          ? Map<String, dynamic>.from(json['controlProfile'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  ShedModel copyWith({
    String? id,
    String? farmId,
    String? name,
    int? capacity,
    double? areaSqMeters,
    String? activeBatchId,
    DateTime? createdAt,
    String? notes,
    bool? isActive,
    Map<String, dynamic>? controlProfile,
    DateTime? updatedAt,
  }) {
    return ShedModel(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      areaSqMeters: areaSqMeters ?? this.areaSqMeters,
      activeBatchId: activeBatchId ?? this.activeBatchId,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      controlProfile: controlProfile ?? this.controlProfile,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
