import '../../services/hive_service.dart';
import '../models/health_treatment_model.dart';

class HealthTreatmentRepository {
  Future<HealthTreatmentModel> create(HealthTreatmentModel treatment) async {
    await HiveService.treatmentBox.put(treatment.id, treatment);
    return treatment;
  }

  Future<HealthTreatmentModel> update(HealthTreatmentModel treatment) async {
    await HiveService.treatmentBox.put(treatment.id, treatment);
    return treatment;
  }

  Future<List<HealthTreatmentModel>> getByFarm(String farmId) async {
    return HiveService.treatmentBox.values
        .where((treatment) => treatment.farmId == farmId)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  Future<List<HealthTreatmentModel>> getByShed(String shedId) async {
    return HiveService.treatmentBox.values
        .where((treatment) => treatment.shedId == shedId)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  Future<void> delete(String id) async {
    await HiveService.treatmentBox.delete(id);
  }
}
