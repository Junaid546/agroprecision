class ShedControlProfile {
  final double targetTempMinC;
  final double targetTempMaxC;
  final double humidityMinPercent;
  final double humidityMaxPercent;
  final double ammoniaMaxPpm;
  final double co2MaxPpm;
  final double feedBinLowPercent;
  final double waterLowPercent;
  final String ventilationMode;
  final String heatingMode;
  final String coolingMode;
  final String lightingMode;
  final String preferredInspectionTime;

  const ShedControlProfile({
    required this.targetTempMinC,
    required this.targetTempMaxC,
    required this.humidityMinPercent,
    required this.humidityMaxPercent,
    required this.ammoniaMaxPpm,
    required this.co2MaxPpm,
    required this.feedBinLowPercent,
    required this.waterLowPercent,
    required this.ventilationMode,
    required this.heatingMode,
    required this.coolingMode,
    required this.lightingMode,
    required this.preferredInspectionTime,
  });

  factory ShedControlProfile.defaults({int ageDays = 1}) {
    if (ageDays <= 7) {
      return const ShedControlProfile(
        targetTempMinC: 31,
        targetTempMaxC: 33,
        humidityMinPercent: 50,
        humidityMaxPercent: 70,
        ammoniaMaxPpm: 15,
        co2MaxPpm: 3000,
        feedBinLowPercent: 25,
        waterLowPercent: 30,
        ventilationMode: 'Minimum',
        heatingMode: 'Auto',
        coolingMode: 'Standby',
        lightingMode: 'Brooding',
        preferredInspectionTime: '07:00',
      );
    }
    if (ageDays <= 21) {
      return const ShedControlProfile(
        targetTempMinC: 27,
        targetTempMaxC: 30,
        humidityMinPercent: 50,
        humidityMaxPercent: 70,
        ammoniaMaxPpm: 20,
        co2MaxPpm: 3000,
        feedBinLowPercent: 25,
        waterLowPercent: 30,
        ventilationMode: 'Transitional',
        heatingMode: 'Auto',
        coolingMode: 'Standby',
        lightingMode: 'Standard',
        preferredInspectionTime: '07:00',
      );
    }
    return const ShedControlProfile(
      targetTempMinC: 21,
      targetTempMaxC: 26,
      humidityMinPercent: 50,
      humidityMaxPercent: 70,
      ammoniaMaxPpm: 20,
      co2MaxPpm: 3000,
      feedBinLowPercent: 25,
      waterLowPercent: 30,
      ventilationMode: 'Tunnel',
      heatingMode: 'Standby',
      coolingMode: 'Auto',
      lightingMode: 'Grow-out',
      preferredInspectionTime: '07:00',
    );
  }

  factory ShedControlProfile.fromMap(Map<String, dynamic>? map,
      {int ageDays = 1}) {
    final defaults = ShedControlProfile.defaults(ageDays: ageDays);
    if (map == null) {
      return defaults;
    }
    return ShedControlProfile(
      targetTempMinC:
          (map['targetTempMinC'] as num?)?.toDouble() ?? defaults.targetTempMinC,
      targetTempMaxC:
          (map['targetTempMaxC'] as num?)?.toDouble() ?? defaults.targetTempMaxC,
      humidityMinPercent: (map['humidityMinPercent'] as num?)?.toDouble() ??
          defaults.humidityMinPercent,
      humidityMaxPercent: (map['humidityMaxPercent'] as num?)?.toDouble() ??
          defaults.humidityMaxPercent,
      ammoniaMaxPpm:
          (map['ammoniaMaxPpm'] as num?)?.toDouble() ?? defaults.ammoniaMaxPpm,
      co2MaxPpm:
          (map['co2MaxPpm'] as num?)?.toDouble() ?? defaults.co2MaxPpm,
      feedBinLowPercent: (map['feedBinLowPercent'] as num?)?.toDouble() ??
          defaults.feedBinLowPercent,
      waterLowPercent:
          (map['waterLowPercent'] as num?)?.toDouble() ?? defaults.waterLowPercent,
      ventilationMode:
          map['ventilationMode'] as String? ?? defaults.ventilationMode,
      heatingMode: map['heatingMode'] as String? ?? defaults.heatingMode,
      coolingMode: map['coolingMode'] as String? ?? defaults.coolingMode,
      lightingMode: map['lightingMode'] as String? ?? defaults.lightingMode,
      preferredInspectionTime: map['preferredInspectionTime'] as String? ??
          defaults.preferredInspectionTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetTempMinC': targetTempMinC,
      'targetTempMaxC': targetTempMaxC,
      'humidityMinPercent': humidityMinPercent,
      'humidityMaxPercent': humidityMaxPercent,
      'ammoniaMaxPpm': ammoniaMaxPpm,
      'co2MaxPpm': co2MaxPpm,
      'feedBinLowPercent': feedBinLowPercent,
      'waterLowPercent': waterLowPercent,
      'ventilationMode': ventilationMode,
      'heatingMode': heatingMode,
      'coolingMode': coolingMode,
      'lightingMode': lightingMode,
      'preferredInspectionTime': preferredInspectionTime,
    };
  }

  ShedControlProfile copyWith({
    double? targetTempMinC,
    double? targetTempMaxC,
    double? humidityMinPercent,
    double? humidityMaxPercent,
    double? ammoniaMaxPpm,
    double? co2MaxPpm,
    double? feedBinLowPercent,
    double? waterLowPercent,
    String? ventilationMode,
    String? heatingMode,
    String? coolingMode,
    String? lightingMode,
    String? preferredInspectionTime,
  }) {
    return ShedControlProfile(
      targetTempMinC: targetTempMinC ?? this.targetTempMinC,
      targetTempMaxC: targetTempMaxC ?? this.targetTempMaxC,
      humidityMinPercent: humidityMinPercent ?? this.humidityMinPercent,
      humidityMaxPercent: humidityMaxPercent ?? this.humidityMaxPercent,
      ammoniaMaxPpm: ammoniaMaxPpm ?? this.ammoniaMaxPpm,
      co2MaxPpm: co2MaxPpm ?? this.co2MaxPpm,
      feedBinLowPercent: feedBinLowPercent ?? this.feedBinLowPercent,
      waterLowPercent: waterLowPercent ?? this.waterLowPercent,
      ventilationMode: ventilationMode ?? this.ventilationMode,
      heatingMode: heatingMode ?? this.heatingMode,
      coolingMode: coolingMode ?? this.coolingMode,
      lightingMode: lightingMode ?? this.lightingMode,
      preferredInspectionTime:
          preferredInspectionTime ?? this.preferredInspectionTime,
    );
  }
}
