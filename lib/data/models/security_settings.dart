class SecuritySettingsData {
  final bool appLockEnabled;
  final String? pin;

  const SecuritySettingsData({
    this.appLockEnabled = false,
    this.pin,
  });

  factory SecuritySettingsData.fromMap(Map<dynamic, dynamic>? map) {
    return SecuritySettingsData(
      appLockEnabled: map?['appLockEnabled'] as bool? ?? false,
      pin: map?['pin'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appLockEnabled': appLockEnabled,
      'pin': pin,
    };
  }

  SecuritySettingsData copyWith({
    bool? appLockEnabled,
    String? pin,
  }) {
    return SecuritySettingsData(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      pin: pin ?? this.pin,
    );
  }
}
