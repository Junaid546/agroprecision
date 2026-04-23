import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'mortality_model.g.dart';

@HiveType(typeId: 4)
class MortalityModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String batchId;

  @HiveField(2)
  String farmId;

  @HiveField(3)
  int count;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? cause;

  @HiveField(6)
  String? notes;

  @HiveField(7)
  DateTime createdAt;

  MortalityModel({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.count,
    required this.date,
    this.cause,
    this.notes,
    required this.createdAt,
  });

  factory MortalityModel.create({
    required String batchId,
    required String farmId,
    required int count,
    required DateTime date,
    String? cause,
    String? notes,
  }) {
    return MortalityModel(
      id: const Uuid().v4(),
      batchId: batchId,
      farmId: farmId,
      count: count,
      date: date,
      cause: cause,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'count': count,
      'date': date.toIso8601String(),
      'cause': cause,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MortalityModel.fromJson(Map<String, dynamic> json) {
    return MortalityModel(
      id: json['id'],
      batchId: json['batchId'],
      farmId: json['farmId'],
      count: json['count'],
      date: DateTime.parse(json['date']),
      cause: json['cause'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
