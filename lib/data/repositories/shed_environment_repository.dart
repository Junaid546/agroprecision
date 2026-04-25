import '../../services/hive_service.dart';
import '../models/shed_environment_reading_model.dart';

class ShedEnvironmentRepository {
  Future<ShedEnvironmentReadingModel> create(
      ShedEnvironmentReadingModel reading) async {
    await HiveService.environmentBox.put(reading.id, reading);
    return reading;
  }

  Future<List<ShedEnvironmentReadingModel>> getByShed(String shedId) async {
    return HiveService.getEnvironmentReadingsForShed(shedId);
  }

  Future<ShedEnvironmentReadingModel?> getLatest(String shedId) async {
    final items = await getByShed(shedId);
    return items.isEmpty ? null : items.first;
  }

  Future<void> delete(String id) async {
    await HiveService.environmentBox.delete(id);
  }
}
