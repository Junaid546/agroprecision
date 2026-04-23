import 'package:flutter/material.dart';
import '../../services/hive_service.dart';
import '../models/shed_model.dart';

class ShedRepository {
  Future<ShedModel> create(ShedModel shed) async {
    await HiveService.shedBox.put(shed.id, shed);
    return shed;
  }

  Future<ShedModel?> getById(String id) async {
    return HiveService.shedBox.get(id);
  }

  Future<List<ShedModel>> getAll() async {
    return HiveService.shedBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<List<ShedModel>> getByFarm(String farmId) async {
    return HiveService.shedBox.values.where((s) => s.farmId == farmId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<ShedModel> update(ShedModel shed) async {
    await shed.save();
    return shed;
  }

  Future<void> delete(String id) async {
    await HiveService.shedBox.delete(id);
  }

  Future<List<ShedModel>> getActiveByFarm(String farmId) async {
    return HiveService.shedBox.values
        .where((s) => s.farmId == farmId && s.isActive)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}
