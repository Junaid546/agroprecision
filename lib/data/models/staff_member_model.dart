import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'staff_member_model.g.dart';

@HiveType(typeId: 19)
class StaffMemberModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String name;

  @HiveField(3)
  String role;

  @HiveField(4)
  String? phone;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  String? notes;

  StaffMemberModel({
    required this.id,
    required this.farmId,
    required this.name,
    required this.role,
    this.phone,
    this.isActive = true,
    required this.createdAt,
    this.notes,
  });

  factory StaffMemberModel.create({
    required String farmId,
    required String name,
    required String role,
    String? phone,
    String? notes,
  }) {
    return StaffMemberModel(
      id: const Uuid().v4(),
      farmId: farmId,
      name: name,
      role: role,
      phone: phone,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'role': role,
      'phone': phone,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory StaffMemberModel.fromJson(Map<String, dynamic> json) {
    return StaffMemberModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }
}
