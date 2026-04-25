class FarmPreferencesData {
  final bool pushNotifications;
  final bool emailAlerts;
  final bool smsAlerts;
  final bool mortalityAlerts;
  final bool feedAlerts;
  final bool environmentAlerts;
  final bool stockAlerts;
  final String currencySymbol;
  final bool metricUnits;
  final bool use24HourTime;

  const FarmPreferencesData({
    this.pushNotifications = true,
    this.emailAlerts = false,
    this.smsAlerts = false,
    this.mortalityAlerts = true,
    this.feedAlerts = true,
    this.environmentAlerts = true,
    this.stockAlerts = true,
    this.currencySymbol = '\$',
    this.metricUnits = true,
    this.use24HourTime = true,
  });

  factory FarmPreferencesData.fromMap(Map<String, dynamic>? map) {
    return FarmPreferencesData(
      pushNotifications: map?['pushNotifications'] as bool? ?? true,
      emailAlerts: map?['emailAlerts'] as bool? ?? false,
      smsAlerts: map?['smsAlerts'] as bool? ?? false,
      mortalityAlerts: map?['mortalityAlerts'] as bool? ?? true,
      feedAlerts: map?['feedAlerts'] as bool? ?? true,
      environmentAlerts: map?['environmentAlerts'] as bool? ?? true,
      stockAlerts: map?['stockAlerts'] as bool? ?? true,
      currencySymbol: map?['currencySymbol'] as String? ?? '\$',
      metricUnits: map?['metricUnits'] as bool? ?? true,
      use24HourTime: map?['use24HourTime'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailAlerts': emailAlerts,
      'smsAlerts': smsAlerts,
      'mortalityAlerts': mortalityAlerts,
      'feedAlerts': feedAlerts,
      'environmentAlerts': environmentAlerts,
      'stockAlerts': stockAlerts,
      'currencySymbol': currencySymbol,
      'metricUnits': metricUnits,
      'use24HourTime': use24HourTime,
    };
  }

  FarmPreferencesData copyWith({
    bool? pushNotifications,
    bool? emailAlerts,
    bool? smsAlerts,
    bool? mortalityAlerts,
    bool? feedAlerts,
    bool? environmentAlerts,
    bool? stockAlerts,
    String? currencySymbol,
    bool? metricUnits,
    bool? use24HourTime,
  }) {
    return FarmPreferencesData(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      mortalityAlerts: mortalityAlerts ?? this.mortalityAlerts,
      feedAlerts: feedAlerts ?? this.feedAlerts,
      environmentAlerts: environmentAlerts ?? this.environmentAlerts,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      metricUnits: metricUnits ?? this.metricUnits,
      use24HourTime: use24HourTime ?? this.use24HourTime,
    );
  }
}
