import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 9)
enum ExpenseCategory {
  @HiveField(0)
  feed,
  @HiveField(1)
  medication,
  @HiveField(2)
  labor,
  @HiveField(3)
  utilities,
  @HiveField(4)
  other;

  String get displayName => {
        ExpenseCategory.feed: 'Feed',
        ExpenseCategory.medication: 'Medication',
        ExpenseCategory.labor: 'Labor',
        ExpenseCategory.utilities: 'Utilities',
        ExpenseCategory.other: 'Other'
      }[this]!;

  Color get color => {
        ExpenseCategory.feed: AppColors.primary,
        ExpenseCategory.medication: AppColors.secondary,
        ExpenseCategory.labor: AppColors.tertiary,
        ExpenseCategory.utilities: AppColors.outline,
        ExpenseCategory.other: AppColors.onSurfaceVariant
      }[this]!;
}

@HiveType(typeId: 3)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String batchId;

  @HiveField(2)
  String farmId;

  @HiveField(3)
  ExpenseCategory category;

  @HiveField(4)
  double amount;

  @HiveField(5)
  String description;

  @HiveField(6)
  DateTime date;

  @HiveField(7)
  double? quantity;

  @HiveField(8)
  String? unit;

  @HiveField(9)
  DateTime createdAt;

  @HiveField(10)
  String? receiptImagePath;

  ExpenseModel({
    required this.id,
    required this.batchId,
    required this.farmId,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.quantity,
    this.unit,
    required this.createdAt,
    this.receiptImagePath,
  });

  factory ExpenseModel.create({
    required String batchId,
    required String farmId,
    required ExpenseCategory category,
    required double amount,
    required String description,
    required DateTime date,
    double? quantity,
    String? unit,
    String? receiptImagePath,
  }) {
    return ExpenseModel(
      id: const Uuid().v4(),
      batchId: batchId,
      farmId: farmId,
      category: category,
      amount: amount,
      description: description,
      date: date,
      quantity: quantity,
      unit: unit,
      createdAt: DateTime.now(),
      receiptImagePath: receiptImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'farmId': farmId,
      'category': category.name,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'quantity': quantity,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'receiptImagePath': receiptImagePath,
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      batchId: json['batchId'],
      farmId: json['farmId'],
      category: ExpenseCategory.values.byName(json['category']),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      quantity: json['quantity'] != null
          ? (json['quantity'] as num).toDouble()
          : null,
      unit: json['unit'],
      createdAt: DateTime.parse(json['createdAt']),
      receiptImagePath: json['receiptImagePath'],
    );
  }
}
