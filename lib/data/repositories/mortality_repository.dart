import '../../services/hive_service.dart';
import '../models/mortality_model.dart';

class WeeklyMortalityData {
  final int week;
  final int count;
  final DateTime weekStart;
  
  WeeklyMortalityData({
    required this.week,
    required this.count,
    required this.weekStart,
  });
}

class MortalityRepository {
  Future<MortalityModel> create(MortalityModel log) async {
    await HiveService.mortalityBox.put(log.id, log);
    return log;
  }

  Future<List<MortalityModel>> getByBatch(String batchId) async {
    return HiveService.getMortalityForBatch(batchId);
  }

  Future<List<MortalityModel>> getByDateRange(String batchId, DateTime start, DateTime end) async {
    return HiveService.getMortalityForBatch(batchId)
        .where((m) => m.date.isAfter(start) && m.date.isBefore(end))
        .toList();
  }

  Future<int> getTotalForBatch(String batchId) async {
    return HiveService.getMortalityForBatch(batchId)
        .fold<int>(0, (sum, m) => sum + m.count);
  }
  
  // Weekly mortality breakdown for chart (W1, W2, W3...)
  Future<List<WeeklyMortalityData>> getWeeklyBreakdown(String batchId) async {
    final batch = await HiveService.batchBox.get(batchId);
    if (batch == null) return [];

    final logs = HiveService.getMortalityForBatch(batchId);
    final Map<int, int> weeklyCounts = {};
    
    for (final log in logs) {
      final daysSinceStart = log.date.difference(batch.startDate).inDays;
      final weekNum = (daysSinceStart / 7).floor() + 1;
      weeklyCounts[weekNum] = (weeklyCounts[weekNum] ?? 0) + log.count;
    }

    final List<WeeklyMortalityData> breakdown = [];
    final maxWeek = weeklyCounts.keys.isEmpty ? 0 : weeklyCounts.keys.reduce((a, b) => a > b ? a : b);

    for (int w = 1; w <= maxWeek; w++) {
      breakdown.add(WeeklyMortalityData(
        week: w,
        count: weeklyCounts[w] ?? 0,
        weekStart: batch.startDate.add(Duration(days: (w - 1) * 7)),
      ));
    }

    return breakdown;
  }
  
  Future<int> getTodaysMortality(String batchId) async {
    final today = DateTime.now();
    final logs = await getByBatch(batchId);
    return logs
        .where((m) => m.date.year == today.year && m.date.month == today.month && m.date.day == today.day)
        .fold<int>(0, (sum, m) => sum + m.count);
  }

  Future<void> delete(String id) async {
    await HiveService.mortalityBox.delete(id);
  }
}
