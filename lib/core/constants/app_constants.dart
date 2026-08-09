/// Product/simulation tuning knobs, kept in one place so the safety rules
/// are easy to point at in a review.
class AppConstants {
  AppConstants._();

  /// Speed above this raises the overspeed safety alert.
  static const double speedLimitKmh = 50;

  /// How often the simulated driver location advances.
  static const Duration tickInterval = Duration(seconds: 3);

  /// Consecutive ticks without a position change before the
  /// "location lost" safety alert is raised.
  static const int staleTickThreshold = 2;

  /// A resolved alert stays visible (in its green state) this many ticks
  /// before it is dismissed.
  static const int resolvedAlertHoldTicks = 2;

  /// Assumed average speed used to estimate the ETA from remaining distance.
  static const double etaAverageSpeedKmh = 26;

  /// Trip progress after which the status reads "Almost there".
  static const double almostThereProgress = 0.82;

  /// Simulated latency for the initial trip fetch and for raising an SOS.
  static const Duration mockLoadDelay = Duration(milliseconds: 900);
  static const Duration mockSosDelay = Duration(milliseconds: 1200);
}
