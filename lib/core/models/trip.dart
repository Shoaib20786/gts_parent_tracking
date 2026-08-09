/// Static facts about the active journey. Everything that changes during the
/// trip (position, speed, ETA, alerts) lives in ActiveTripProvider instead.
class Trip {
  const Trip({
    required this.childName,
    required this.driverName,
    required this.driverRating,
    required this.driverTripCount,
    required this.vehicle,
    required this.plate,
    required this.schoolName,
    required this.destinationLabel,
    required this.pickupTimeLabel,
  });

  final String childName;
  final String driverName;
  final double driverRating;
  final int driverTripCount;
  final String vehicle;
  final String plate;
  final String schoolName;
  final String destinationLabel;
  final String pickupTimeLabel;

  /// "Ramesh Kumar" -> "RK", used for the avatar.
  String get driverInitials =>
      driverName.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
}
