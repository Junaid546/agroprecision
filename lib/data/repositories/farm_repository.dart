import '../models/farm_model.dart';
import '../../services/hive_service.dart';

class FarmRepository {
  Future<List<FarmModel>> getAll() async {
    return HiveService.farmBox.values.toList();
  }

  Future<FarmModel?> getById(String id) async {
    return HiveService.farmBox.get(id);
  }

  Future<void> create(FarmModel farm) async {
    await HiveService.farmBox.put(farm.id, farm);
  }

  Future<void> update(FarmModel farm) async {
    await HiveService.farmBox.put(farm.id, farm);
  }

  Future<void> delete(String id) async {
    await HiveService.farmBox.delete(id);
  }
}
