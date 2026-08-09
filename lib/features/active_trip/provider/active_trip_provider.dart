import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/driver_location.dart';
import '../../../core/models/safety_alert.dart';
import '../../../core/models/trip.dart';
import '../data/mock_trip_data.dart';

enum TripLoadState { loading, error, ready }

enum TripStatus {
  leavingSchool('Trip started'),
  onTheWay('On the way'),
  almostThere('Almost there'),
  arrived('Arrived');

  const TripStatus(this.label);
  final String label;
}

enum SosState { idle, raising, raised }

/// Owns the whole active-trip state: the mock "fetch", the simulation timer,
/// and every derived value the UI shows.
///
/// Design note: everything (speed, distance, ETA, status, alerts) is derived
/// purely from the current tick index into [MockTripData.timeline]. Advancing
/// the trip, jumping to a demo scenario, and unit-testing all go through the
/// same [_seek] — so the demo is deterministic and there is no hidden state to
/// drift out of sync.
class ActiveTripProvider extends ChangeNotifier {
  ActiveTripProvider({this.autoStart = true});

  /// Tests pass false so no periodic timer is created.
  final bool autoStart;

  static const List<DriverLocation> _timeline = MockTripData.timeline;

  TripLoadState _loadState = TripLoadState.loading;
  Trip? _trip;
  int _tick = 0;
  bool _paused = false;
  Timer? _timer;
  SosState _sosState = SosState.idle;

  // ── Load ──────────────────────────────────────────────────────────────────

  TripLoadState get loadState => _loadState;
  Trip get trip => _trip!;

  /// Simulates fetching the active trip, then starts the journey simulation.
  Future<void> init({Duration loadDelay = AppConstants.mockLoadDelay}) async {
    _loadState = TripLoadState.loading;
    notifyListeners();
    await Future<void>.delayed(loadDelay);
    _trip = MockTripData.trip;
    _loadState = TripLoadState.ready;
    _seek(0);
    if (autoStart) _startTimer();
  }

  // ── Simulation ────────────────────────────────────────────────────────────

  bool get isPaused => _paused;
  bool get hasArrived => _location.progress >= 1.0;

  DriverLocation get _location => _timeline[_tick];

  /// 0..1 along the route — the map animates between values of this.
  double get progress => _location.progress;

  LatLng get driverPosition => MockTripData.route.positionAt(progress);

  double get speedKmh => _location.speedKmh;

  double get remainingKm => (1 - progress) * MockTripData.route.totalKm;

  int get etaMinutes => hasArrived
      ? 0
      : math.max(1, (remainingKm / AppConstants.etaAverageSpeedKmh * 60).ceil());

  /// Wall-clock arrival estimate, e.g. "3:42 PM".
  String get arrivalClock => _formatClock(DateTime.now().add(Duration(minutes: etaMinutes)));

  TripStatus get status {
    if (hasArrived) return TripStatus.arrived;
    if (progress >= AppConstants.almostThereProgress) return TripStatus.almostThere;
    if (_tick == 0) return TripStatus.leavingSchool;
    return TripStatus.onTheWay;
  }

  void _startTimer() {
    _timer?.cancel();
    _paused = false;
    _timer = Timer.periodic(AppConstants.tickInterval, (_) => _onTick());
  }

  void _onTick() {
    if (_paused || _loadState != TripLoadState.ready) return;
    if (_tick >= _timeline.length - 1) {
      _timer?.cancel();
      return;
    }
    _seek(_tick + 1);
  }

  void _seek(int tick) {
    _tick = tick.clamp(0, _timeline.length - 1);
    notifyListeners();
  }

  // ── Safety alerts (pure derivation from the timeline) ─────────────────────

  /// Consecutive ticks (ending at [tick]) during which the position has not
  /// changed while the trip is still running.
  int _staleRun(int tick) {
    var run = 0;
    while (tick - run > 0 &&
        _timeline[tick - run].progress == _timeline[tick - run - 1].progress &&
        _timeline[tick - run].progress < 1.0) {
      run++;
    }
    return run;
  }

  bool _isOverspeed(int tick) => _timeline[tick].speedKmh > AppConstants.speedLimitKmh;

  bool _isStale(int tick) => _staleRun(tick) >= AppConstants.staleTickThreshold;

  /// True if [test] held within the last [AppConstants.resolvedAlertHoldTicks]
  /// ticks before [tick] — drives the brief green "resolved" state.
  bool _recently(int tick, bool Function(int) test) {
    for (var i = 1; i <= AppConstants.resolvedAlertHoldTicks; i++) {
      if (tick - i >= 0 && test(tick - i)) return true;
    }
    return false;
  }

  bool get locationIsStale => _isStale(_tick);

  SafetyAlert? get activeAlert {
    if (_isOverspeed(_tick)) {
      return SafetyAlert(
        type: SafetyAlertType.overspeed,
        detail: 'Current speed ${speedKmh.round()} km/h · '
            'Safe limit ${AppConstants.speedLimitKmh.round()} km/h',
      );
    }
    if (_isStale(_tick)) {
      final seconds = _staleRun(_tick) * AppConstants.tickInterval.inSeconds;
      return SafetyAlert(
        type: SafetyAlertType.locationLost,
        detail: 'Last update ${seconds}s ago · Reconnecting automatically',
      );
    }
    if (_recently(_tick, _isOverspeed)) {
      return SafetyAlert(
        type: SafetyAlertType.overspeed,
        resolved: true,
        detail: 'The driver has slowed back down. No action needed.',
      );
    }
    if (_recently(_tick, _isStale)) {
      return const SafetyAlert(
        type: SafetyAlertType.locationLost,
        resolved: true,
        detail: 'Live tracking has resumed. No action needed.',
      );
    }
    return null;
  }

  // ── SOS ───────────────────────────────────────────────────────────────────

  SosState get sosState => _sosState;

  /// Simulates raising an SOS with the GTS safety team. No real emergency
  /// integration — see README.
  Future<void> raiseSos() async {
    if (_sosState != SosState.idle) return;
    _sosState = SosState.raising;
    notifyListeners();
    await Future<void>.delayed(AppConstants.mockSosDelay);
    _sosState = SosState.raised;
    notifyListeners();
  }

  // ── Demo controls (also the test API) ─────────────────────────────────────

  void togglePause() {
    _paused = !_paused;
    notifyListeners();
  }

  void jumpToOverspeed() => _resumeAt(MockTripData.overspeedTick);

  void jumpToLocationLoss() => _resumeAt(MockTripData.locationLostTick);

  void jumpNearArrival() => _resumeAt(MockTripData.nearArrivalTick);

  void restartTrip() {
    _sosState = SosState.idle;
    _resumeAt(0);
  }

  void _resumeAt(int tick) {
    // Re-arm the timer: it may have completed (arrival) or be paused.
    if (autoStart) _startTimer();
    _seek(tick);
  }

  /// Tests need to reach arbitrary points of the timeline (e.g. the tick after
  /// an alert clears) that the demo jumps don't cover.
  @visibleForTesting
  void debugSeek(int tick) => _seek(tick);

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
