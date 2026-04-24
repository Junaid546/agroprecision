import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 6)
class SaleModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String batchId;

  @HiveField(2)
  String farmId;

  @HiveField(3)
  int birdsSold;

  @HiveField(4)
  double pricePerKg;

  @HiveField(5)
  double averageWeightKg;

  @HiveField(6)
  double totalRevenue;

  @HiveField(7)
  DateTime saleDate;

  @HiveField(8)
  String? buyerName;

  @HiveField(9)
  String? notes;

  @HiveField(10)
  DateTime createdAt;

  SaleModel({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.birdsSold,
    required this.pricePerKg,
    required this.averageWeightKg,
    required this.totalRevenue,
    required this.saleDate,
    this.buyerName,
    this.notes,
    required this.createdAt,
  });

  factory SaleModel.create({
    required String batchId,
    required String farmId,
    required int birdsSold,
    required double pricePerKg,
    required double averageWeightKg,
    required DateTime saleDate,
    String? buyerName,
    String? notes,
  }) {
    // Validation: totalRevenue must equal birdsSold * averageWeightKg * pricePerKg
    final totalRevenue = birdsSold * averageWeightKg * pricePerKg;

    return SaleModel(
      id: const Uuid().v4(),
      batchId: batchId,
      farmId: farmId,
      birdsSold: birdsSold,
      pricePerKg: pricePerKg,
      averageWeightKg: averageWeightKg,
      totalRevenue: totalRevenue,
      saleDate: saleDate,
      buyerName: buyerName,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'birdsSold': birdsSold,
      'pricePerKg': pricePerKg,
      'averageWeightKg': averageWeightKg,
      'totalRevenue': totalRevenue,
      'saleDate': saleDate.toIso8601String(),
      'buyerName': buyerName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'],
      batchId: json['batchId'],
      farmId: json['farmId'],
      birdsSold: json['birdsSold'],
      pricePerKg: (json['pricePerKg'] as num).toDouble(),
      averageWeightKg: (json['averageWeightKg'] as num).toDouble(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      saleDate: DateTime.parse(json['saleDate']),
      buyerName: json['buyerName'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
