/// One simulated location sample.
///
/// [progress] is 0..1 along the mock route polyline rather than a raw lat/lng,
/// which keeps the timeline readable and lets the geometry helper resolve the
/// actual map position. A repeated [progress] with zero speed models the
/// "location stopped / unavailable" scenario.
class DriverLocation {
  const DriverLocation({required this.progress, required this.speedKmh});

  final double progress;
  final double speedKmh;
}
