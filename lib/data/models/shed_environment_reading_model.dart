import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'shed_environment_reading_model.g.dart';

@HiveType(typeId: 15)
class ShedEnvironmentReadingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String farmId;

  @HiveField(2)
  String shedId;

  @HiveField(3)
  DateTime recordedAt;

  @HiveField(4)
  double temperatureC;

  @HiveField(5)
  double humidityPercent;

  @HiveField(6)
  double? ammoniaPpm;

  @HiveField(7)
  double? co2Ppm;

  @HiveField(8)
  double? staticPressurePa;

  @HiveField(9)
  double? airSpeedMps;

  @HiveField(10)
  double? feedBinLevelPercent;

  @HiveField(11)
  double? waterLevelPercent;

  @HiveField(12)
  String? notes;

  @HiveField(13)
  DateTime createdAt;

  ShedEnvironmentReadingModel({
    required this.id,
    required this.farmId,
    required this.shedId,
    required this.recordedAt,
    required this.temperatureC,
    required this.humidityPercent,
    this.ammoniaPpm,
    this.co2Ppm,
    this.staticPressurePa,
    this.airSpeedMps,
    this.feedBinLevelPercent,
    this.waterLevelPercent,
    this.notes,
    required this.createdAt,
  });

  factory ShedEnvironmentReadingModel.create({
    required String farmId,
    required String shedId,
    required DateTime recordedAt,
    required double temperatureC,
    required double humidityPercent,
    double? ammoniaPpm,
    double? co2Ppm,
    double? staticPressurePa,
    double? airSpeedMps,
    double? feedBinLevelPercent,
    double? waterLevelPercent,
    String? notes,
  }) {
    return ShedEnvironmentReadingModel(
      id: const Uuid().v4(),
      farmId: farmId,
      shedId: shedId,
      recordedAt: recordedAt,
      temperatureC: temperatureC,
      humidityPercent: humidityPercent,
      ammoniaPpm: ammoniaPpm,
      co2Ppm: co2Ppm,
      staticPressurePa: staticPressurePa,
      airSpeedMps: airSpeedMps,
      feedBinLevelPercent: feedBinLevelPercent,
      waterLevelPercent: waterLevelPercent,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'shedId': shedId,
      'recordedAt': recordedAt.toIso8601String(),
      'temperatureC': temperatureC,
      'humidityPercent': humidityPercent,
      'ammoniaPpm': ammoniaPpm,
      'co2Ppm': co2Ppm,
      'staticPressurePa': staticPressurePa,
      'airSpeedMps': airSpeedMps,
      'feedBinLevelPercent': feedBinLevelPercent,
      'waterLevelPercent': waterLevelPercent,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShedEnvironmentReadingModel.fromJson(Map<String, dynamic> json) {
    return ShedEnvironmentReadingModel(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      shedId: json['shedId'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      temperatureC: (json['temperatureC'] as num).toDouble(),
      humidityPercent: (json['humidityPercent'] as num).toDouble(),
      ammoniaPpm: (json['ammoniaPpm'] as num?)?.toDouble(),
      co2Ppm: (json['co2Ppm'] as num?)?.toDouble(),
      staticPressurePa: (json['staticPressurePa'] as num?)?.toDouble(),
      airSpeedMps: (json['airSpeedMps'] as num?)?.toDouble(),
      feedBinLevelPercent:
          (json['feedBinLevelPercent'] as num?)?.toDouble(),
      waterLevelPercent: (json['waterLevelPercent'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
          (json['createdAt'] ?? json['recordedAt']) as String),
    );
  }
}
