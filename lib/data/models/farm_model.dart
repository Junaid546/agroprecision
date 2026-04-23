import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'farm_model.g.dart';

@HiveType(typeId: 0)
class FarmModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String ownerName;

  @HiveField(3)
  String? location;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  List<String> shedIds;

  @HiveField(8)
  bool isSetupComplete;

  @HiveField(9)
  Map<String, dynamic>? preferences;

  FarmModel({
    required this.id,
    required this.name,
    required this.ownerName,
    this.location,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.shedIds = const [],
    this.isSetupComplete = false,
    this.preferences,
  });

  factory FarmModel.create({
    required String name,
    required String ownerName,
    String? location,
    String? phone,
  }) {
    final now = DateTime.now();
    return FarmModel(
      id: const Uuid().v4(),
      name: name,
      ownerName: ownerName,
      location: location,
      phone: phone,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'location': location,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'shedIds': shedIds,
      'isSetupComplete': isSetupComplete,
      'preferences': preferences,
    };
  }

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],
      name: json['name'],
      ownerName: json['ownerName'],
      location: json['location'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      shedIds: List<String>.from(json['shedIds'] ?? []),
      isSetupComplete: json['isSetupComplete'] ?? false,
      preferences: json['preferences'] != null ? Map<String, dynamic>.from(json['preferences']) : null,
    );
  }
}
