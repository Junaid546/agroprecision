import '../../services/hive_service.dart';
import '../models/staff_member_model.dart';

class StaffRepository {
  Future<StaffMemberModel> create(StaffMemberModel member) async {
    await HiveService.staffBox.put(member.id, member);
    return member;
  }

  Future<StaffMemberModel> update(StaffMemberModel member) async {
    await HiveService.staffBox.put(member.id, member);
    return member;
  }

  Future<List<StaffMemberModel>> getByFarm(String farmId) async {
    return HiveService.staffBox.values
        .where((member) => member.farmId == farmId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> delete(String id) async {
    await HiveService.staffBox.delete(id);
  }
}
