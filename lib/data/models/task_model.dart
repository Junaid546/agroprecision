import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';

part 'task_model.g.dart';

@HiveType(typeId: 10)
enum TaskPriority {
  @HiveField(0)
  routine,
  @HiveField(1)
  priority,
  @HiveField(2)
  critical;

  String get displayLabel => {
    TaskPriority.routine: 'ROUTINE',
    TaskPriority.priority: 'PRIORITY',
    TaskPriority.critical: 'CRITICAL'
  }[this]!;

  Color get chipColor => {
    TaskPriority.routine: AppColors.onSurfaceVariant,
    TaskPriority.priority: AppColors.secondary,
    TaskPriority.critical: AppColors.error
  }[this]!;
}

@HiveType(typeId: 11)
enum TaskStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  done,
  @HiveField(2)
  skipped,
}

@HiveType(typeId: 7)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String? batchId;

  @HiveField(3)
  String title;

  @HiveField(4)
  String? description;

  @HiveField(5)
  TaskPriority priority;

  @HiveField(6)
  TaskStatus status;

  @HiveField(7)
  DateTime scheduledDate;

  @HiveField(8)
  String? scheduledTime;

  @HiveField(9)
  bool isRecurring;

  @HiveField(10)
  String? recurringPattern;

  @HiveField(11)
  DateTime? completedAt;

  @HiveField(12)
  DateTime createdAt;

  @HiveField(13)
  int? notificationId;

  @HiveField(14)
  String? shedId;

  TaskModel({
    required this.id,
    required this.farmId,
    this.batchId,
    required this.title,
    this.description,
    this.priority = TaskPriority.routine,
    this.status = TaskStatus.pending,
    required this.scheduledDate,
    this.scheduledTime,
    this.isRecurring = false,
    this.recurringPattern,
    this.completedAt,
    required this.createdAt,
    this.notificationId,
    this.shedId,
  });

  factory TaskModel.create({
    required String farmId,
    String? batchId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.routine,
    required DateTime scheduledDate,
    String? scheduledTime,
    bool isRecurring = false,
    String? recurringPattern,
    int? notificationId,
    String? shedId,
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      farmId: farmId,
      batchId: batchId,
      title: title,
      description: description,
      priority: priority,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
      isRecurring: isRecurring,
      recurringPattern: recurringPattern,
      createdAt: DateTime.now(),
      notificationId: notificationId,
      shedId: shedId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'batchId': batchId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'isRecurring': isRecurring,
      'recurringPattern': recurringPattern,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notificationId': notificationId,
      'shedId': shedId,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      farmId: json['farmId'],
      batchId: json['batchId'],
      title: json['title'],
      description: json['description'],
      priority: TaskPriority.values.byName(json['priority']),
      status: TaskStatus.values.byName(json['status']),
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'],
      isRecurring: json['isRecurring'] ?? false,
      recurringPattern: json['recurringPattern'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      notificationId: json['notificationId'],
      shedId: json['shedId'],
    );
  }
}
