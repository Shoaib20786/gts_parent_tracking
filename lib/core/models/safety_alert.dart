enum SafetyAlertType { overspeed, locationLost }

/// A parent-facing safety condition. Copy lives here so every surface shows
/// the same plain, non-technical language.
class SafetyAlert {
  const SafetyAlert({
    required this.type,
    required this.detail,
    this.resolved = false,
  });

  final SafetyAlertType type;

  /// Supporting line, e.g. "Current speed 63 km/h · Safe limit 50 km/h".
  final String detail;

  /// True while the condition has just cleared — shown briefly in a green
  /// "all good again" state before disappearing.
  final bool resolved;

  String get headline => switch ((type, resolved)) {
        (SafetyAlertType.overspeed, false) =>
          'Driver is travelling faster than the safe limit.',
        (SafetyAlertType.overspeed, true) => 'Speed is back to normal.',
        (SafetyAlertType.locationLost, false) =>
          "We haven't received a location update for a while.",
        (SafetyAlertType.locationLost, true) => "Driver's location is back online.",
      };
}
