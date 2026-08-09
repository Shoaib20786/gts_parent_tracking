import 'package:flutter_test/flutter_test.dart';
import 'package:gts_parent_tracking/core/models/safety_alert.dart';
import 'package:gts_parent_tracking/features/active_trip/data/mock_trip_data.dart';
import 'package:gts_parent_tracking/features/active_trip/provider/active_trip_provider.dart';

void main() {
  group('ActiveTripProvider', () {
    late ActiveTripProvider provider;

    setUp(() async {
      // autoStart: false -> no periodic timer; every state change goes through
      // the same deterministic seek used by the demo controls.
      provider = ActiveTripProvider(autoStart: false);
      await provider.init(loadDelay: Duration.zero);
    });

    tearDown(() => provider.dispose());

    test('loads the trip and starts at the school with no alert', () {
      expect(provider.loadState, TripLoadState.ready);
      expect(provider.trip.childName, isNotEmpty);
      expect(provider.progress, 0);
      expect(provider.status, TripStatus.leavingSchool);
      expect(provider.activeAlert, isNull);
      expect(provider.remainingKm, closeTo(MockTripData.route.totalKm, 0.001));
    });

    test('overspeed tick raises an unresolved overspeed alert', () {
      provider.jumpToOverspeed();

      final alert = provider.activeAlert;
      expect(alert, isNotNull);
      expect(alert!.type, SafetyAlertType.overspeed);
      expect(alert.resolved, isFalse);
      expect(provider.speedKmh, greaterThan(50));
    });

    test('overspeed shows a resolved state after recovery, then clears', () {
      provider.debugSeek(MockTripData.overspeedTick + 2); // first tick back under

      final resolved = provider.activeAlert;
      expect(resolved!.type, SafetyAlertType.overspeed);
      expect(resolved.resolved, isTrue);

      provider.debugSeek(MockTripData.overspeedTick + 4); // hold window over
      expect(provider.activeAlert, isNull);
    });

    test('an unchanged location raises the location-lost alert', () {
      provider.jumpToLocationLoss();

      final alert = provider.activeAlert;
      expect(alert!.type, SafetyAlertType.locationLost);
      expect(alert.resolved, isFalse);
      expect(provider.locationIsStale, isTrue);
      expect(provider.speedKmh, 0);
    });

    test('location recovery resolves the alert, then clears it', () {
      provider.debugSeek(12); // first moving tick after the stall

      final resolved = provider.activeAlert;
      expect(resolved!.type, SafetyAlertType.locationLost);
      expect(resolved.resolved, isTrue);
      expect(provider.locationIsStale, isFalse);

      provider.debugSeek(14);
      expect(provider.activeAlert, isNull);
    });

    test('ETA and distance shrink as the trip progresses', () {
      final etaAtStart = provider.etaMinutes;
      final distanceAtStart = provider.remainingKm;

      provider.jumpNearArrival();

      expect(provider.etaMinutes, lessThan(etaAtStart));
      expect(provider.remainingKm, lessThan(distanceAtStart));
      expect(provider.status, TripStatus.almostThere);
    });

    test('final tick is a clean arrival with no stale-location alert', () {
      provider.debugSeek(MockTripData.timeline.length - 1);

      expect(provider.hasArrived, isTrue);
      expect(provider.status, TripStatus.arrived);
      expect(provider.etaMinutes, 0);
      expect(provider.remainingKm, 0);
      // Standing still because the trip is over is not a safety condition.
      expect(provider.locationIsStale, isFalse);
    });

    test('SOS raises once and resets on trip restart', () async {
      expect(provider.sosState, SosState.idle);

      final raise = provider.raiseSos();
      expect(provider.sosState, SosState.raising);
      await raise;
      expect(provider.sosState, SosState.raised);

      // A second raise while already raised is a no-op.
      await provider.raiseSos();
      expect(provider.sosState, SosState.raised);

      provider.restartTrip();
      expect(provider.sosState, SosState.idle);
      expect(provider.progress, 0);
    });
  });

  group('RouteGeometry', () {
    final route = MockTripData.route;

    test('resolves the endpoints of the polyline', () {
      expect(route.positionAt(0), MockTripData.routePoints.first);
      expect(route.positionAt(1), MockTripData.routePoints.last);
      expect(route.totalKm, greaterThan(3));
    });

    test('splits the route into travelled and remaining paths', () {
      const t = 0.5;
      final travelled = route.travelledPath(t);
      final remaining = route.remainingPath(t);

      expect(travelled.first, route.start);
      expect(remaining.last, route.end);
      // Both halves meet at the driver's current position.
      expect(travelled.last, remaining.first);
    });
  });
}
