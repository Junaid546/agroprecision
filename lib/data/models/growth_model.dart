import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'growth_model.g.dart';

@HiveType(typeId: 5)
class GrowthModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String batchId;

  @HiveField(2)
  String farmId;

  @HiveField(3)
  double averageWeightKg;

  @HiveField(4)
  int sampleSize;

  @HiveField(5)
  int batchDay;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  double? feedConsumedKg;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? notes;

  GrowthModel({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.averageWeightKg,
    required this.sampleSize,
    required this.batchDay,
    required this.date,
    this.feedConsumedKg,
    required this.createdAt,
    this.notes,
  });

  factory GrowthModel.create({
    required String batchId,
    required String farmId,
    required double averageWeightKg,
    required int sampleSize,
    required int batchDay,
    required DateTime date,
    double? feedConsumedKg,
    String? notes,
  }) {
    return GrowthModel(
      id: const Uuid().v4(),
      batchId: batchId,
      farmId: farmId,
      averageWeightKg: averageWeightKg,
      sampleSize: sampleSize,
      batchDay: batchDay,
      date: date,
      feedConsumedKg: feedConsumedKg,
      createdAt: DateTime.now(),
      notes: notes,
    );
  }

  // Computed property
  double get feedConversionRatio {
    if (feedConsumedKg == null || feedConsumedKg! <= 0 || averageWeightKg <= 0) return 0;
    return feedConsumedKg! / averageWeightKg;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'averageWeightKg': averageWeightKg,
      'sampleSize': sampleSize,
      'batchDay': batchDay,
      'date': date.toIso8601String(),
      'feedConsumedKg': feedConsumedKg,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory GrowthModel.fromJson(Map<String, dynamic> json) {
    return GrowthModel(
      id: json['id'],
      batchId: json['batchId'],
      farmId: json['farmId'],
      averageWeightKg: (json['averageWeightKg'] as num).toDouble(),
      sampleSize: json['sampleSize'],
      batchDay: json['batchDay'],
      date: DateTime.parse(json['date']),
      feedConsumedKg: json['feedConsumedKg'] != null ? (json['feedConsumedKg'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt']),
      notes: json['notes'],
    );
  }
}
