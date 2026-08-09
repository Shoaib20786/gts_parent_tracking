import 'package:latlong2/latlong.dart';

import '../../../core/models/driver_location.dart';
import '../../../core/models/trip.dart';

/// All mock/local data driving the prototype, plus the route geometry helper.
/// The assignment explicitly allows simulated data — everything here is
/// deterministic so the demo plays out identically on every run.
class MockTripData {
  MockTripData._();

  static const Trip trip = Trip(
    childName: 'Maya',
    driverName: 'Ramesh Kumar',
    driverRating: 4.8,
    driverTripCount: 962,
    vehicle: 'White Maruti Ertiga',
    plate: 'KA 05 MJ 4021',
    schoolName: 'Greenwood High School',
    destinationLabel: 'Home',
    pickupTimeLabel: '3:05 PM',
  );

  /// School -> home along 100 Feet Road and into the HAL 2nd Stage grid,
  /// Indiranagar, Bengaluru (~4.5 km).
  static final List<LatLng> routePoints = [
    LatLng(12.9784, 77.6408), // school
    LatLng(12.9740, 77.6407),
    LatLng(12.9700, 77.6406),
    LatLng(12.9660, 77.6404),
    LatLng(12.9620, 77.6403),
    LatLng(12.9600, 77.6402),
    LatLng(12.9598, 77.6450),
    LatLng(12.9597, 77.6502),
    LatLng(12.9560, 77.6504),
    LatLng(12.9558, 77.6550),
    LatLng(12.9556, 77.6552), // home
  ];

  static final RouteGeometry route = RouteGeometry(routePoints);

  /// One entry per simulation tick. The scripted story:
  /// normal driving -> overspeed (ticks 4-5) -> recovery -> stall with no
  /// position change (ticks 9-11, raising the location-lost alert) ->
  /// recovery -> arrival.
  static const List<DriverLocation> timeline = [
    DriverLocation(progress: 0.00, speedKmh: 12),
    DriverLocation(progress: 0.05, speedKmh: 24),
    DriverLocation(progress: 0.11, speedKmh: 32),
    DriverLocation(progress: 0.18, speedKmh: 41),
    DriverLocation(progress: 0.26, speedKmh: 57), // over the 50 km/h limit
    DriverLocation(progress: 0.35, speedKmh: 64),
    DriverLocation(progress: 0.43, speedKmh: 45), // back under
    DriverLocation(progress: 0.50, speedKmh: 34),
    DriverLocation(progress: 0.55, speedKmh: 27),
    DriverLocation(progress: 0.55, speedKmh: 0), // stalled
    DriverLocation(progress: 0.55, speedKmh: 0),
    DriverLocation(progress: 0.55, speedKmh: 0),
    DriverLocation(progress: 0.62, speedKmh: 22), // moving again
    DriverLocation(progress: 0.74, speedKmh: 35),
    DriverLocation(progress: 0.86, speedKmh: 38),
    DriverLocation(progress: 0.95, speedKmh: 21),
    DriverLocation(progress: 1.00, speedKmh: 0), // arrived
  ];

  // Named ticks for the demo controls and tests — no magic indices elsewhere.
  static const int overspeedTick = 4;
  static const int locationLostTick = 10;
  static const int nearArrivalTick = 14;
}

/// Resolves a 0..1 progress value to a point along a polyline, and splits the
/// polyline into travelled/remaining halves for the map.
class RouteGeometry {
  RouteGeometry(this.points)
      : assert(points.length >= 2, 'A route needs at least two points') {
    // roundResult: false — the default Distance() rounds to whole units,
    // which would collapse our ~0.4 km segments to 0.
    const distance = Distance(roundResult: false);
    _cumulativeKm = [0];
    for (var i = 1; i < points.length; i++) {
      _cumulativeKm.add(
        _cumulativeKm[i - 1] + distance.as(LengthUnit.Kilometer, points[i - 1], points[i]),
      );
    }
  }

  final List<LatLng> points;
  late final List<double> _cumulativeKm;

  double get totalKm => _cumulativeKm.last;

  LatLng get start => points.first;
  LatLng get end => points.last;

  LatLng positionAt(double t) {
    if (t <= 0) return start;
    if (t >= 1) return end;
    final target = t * totalKm;
    for (var i = 1; i < points.length; i++) {
      if (target <= _cumulativeKm[i]) {
        final segment = _cumulativeKm[i] - _cumulativeKm[i - 1];
        final f = segment == 0 ? 0.0 : (target - _cumulativeKm[i - 1]) / segment;
        return LatLng(
          points[i - 1].latitude + (points[i].latitude - points[i - 1].latitude) * f,
          points[i - 1].longitude + (points[i].longitude - points[i - 1].longitude) * f,
        );
      }
    }
    return end;
  }

  /// Route from the school up to the driver's current position.
  List<LatLng> travelledPath(double t) {
    final target = t.clamp(0.0, 1.0) * totalKm;
    final path = <LatLng>[points.first];
    for (var i = 1; i < points.length && _cumulativeKm[i] < target; i++) {
      path.add(points[i]);
    }
    path.add(positionAt(t));
    return path;
  }

  /// Route from the driver's current position to home.
  List<LatLng> remainingPath(double t) {
    final target = t.clamp(0.0, 1.0) * totalKm;
    final path = <LatLng>[positionAt(t)];
    for (var i = 0; i < points.length; i++) {
      if (_cumulativeKm[i] > target) path.add(points[i]);
    }
    return path;
  }
}
