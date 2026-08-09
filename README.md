# GTS — Parent Trip Tracking Prototype

![Flutter](https://img.shields.io/badge/Flutter-3.35-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Provider-4CAF50)
![Map](https://img.shields.io/badge/Map-flutter__map%20%2B%20OSM-7EBC6F)
![Tests](https://img.shields.io/badge/Tests-10%20passing-brightgreen)

A polished Flutter prototype of the **GTS (Go To Shore)** parent experience: a
parent opens the app while their child is travelling home from school, sees the
live journey at a glance, receives plain-language safety alerts, and can raise
an SOS with an explicit confirmation step.

<p align="center">
  <img src="docs/demo.gif" width="300" alt="GTS demo — live trip, overspeed alert, lost location, arrival, SOS flow"/>
</p>
<p align="center"><sub>One continuous run: live tracking → overspeed alert → recovery → lost location → arrival → SOS confirm → success.</sub></p>

## Screens

| Live trip | Overspeed | Location lost | SOS confirm | SOS raised |
| :---: | :---: | :---: | :---: | :---: |
| <img src="docs/screenshots/live_trip.png" width="160"/> | <img src="docs/screenshots/overspeed_alert.png" width="160"/> | <img src="docs/screenshots/location_lost_alert.png" width="160"/> | <img src="docs/screenshots/sos_confirm.png" width="160"/> | <img src="docs/screenshots/sos_success.png" width="160"/> |
| ETA hero, speed, distance, progress | Red alert, exact speed vs. limit | Amber alert, "NO SIGNAL" chip | Deliberate confirmation step | Persistent success state |

## Features

- **Active trip screen** — child, driver (name, rating, trip count), vehicle +
  plate, school → home, live status pill that a safety alert can take over
- **Real map** — OpenStreetMap via `flutter_map`: travelled route (solid) vs.
  remaining (dashed), school/home markers, an animated driver marker that
  glides between updates with an alert-colored pulsing ring, recenter control
- **Live metrics** — ETA (hero number + wall-clock estimate), current speed,
  distance to destination, school→home progress bar, all recomputed every tick
- **Safety alerts** (plain parent language, no technical jargon)
  - *Overspeeding* — red: "Driver is travelling faster than the safe limit." with current speed vs. limit
  - *Location stopped/unavailable* — amber: "We haven't received a location update for a while." with time since last update
  - Both show a brief green **resolved** state when the condition clears
- **SOS flow** — tap → confirmation sheet → raising → success, then a
  persistent "SOS raised · Safety team notified" bar for the rest of the trip
- **Loading / error / retry** states for the initial trip fetch
- **Demo controls** (tune icon, top-right) — pause/resume, trigger overspeed,
  trigger lost location, jump near arrival, restart

## Run

```bash
flutter pub get
flutter run
```

Internet access is needed for OpenStreetMap tiles; everything else is local.
Built and verified with Flutter 3.35.5 / Dart 3.9.2 on Android.

```bash
flutter test                     # provider + route geometry unit tests
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```

## Architecture

```
lib/
  app/                    MaterialApp + theme tokens (AppColors, AppTextStyles)
  core/
    constants/            safety thresholds & simulation tuning in one place
    models/               Trip, DriverLocation, SafetyAlert
  features/active_trip/
    data/                 mock route (LatLng polyline) + deterministic timeline
                          + RouteGeometry (progress → position, path splitting)
    provider/             ActiveTripProvider — all state & simulation logic
    presentation/         screen + presentational widgets (map, metrics,
                          header, driver card, alert card, SOS button/sheet)
test/                     provider & geometry unit tests (no timers needed)
```

**The key design decision:** every displayed value (position, speed, distance,
ETA, status, alerts) is *derived purely from an index into a deterministic mock
timeline*, advanced by a periodic `Timer`. The demo controls and the unit tests
drive the exact same seek path as the timer — so the demo plays out identically
on every run and the logic is testable without any timer machinery.

The location-lost alert is not scripted directly: the provider detects that the
position hasn't changed for N consecutive ticks — the same rule a real backend
would apply.

## Scope decisions

The assignment explicitly allows mock/local data and requires no backend,
authentication, payments, or real GPS — so those are deliberately out of scope.
Effort went into the parent experience: 3-second comprehension of "is my child
okay", safety states in plain language, an SOS that is hard to trigger
accidentally, and a deterministic demo.

No real emergency service or safety team is contacted by the SOS flow — it is
fully simulated, as permitted by the brief.

## AI tools used

- **Claude Code** (Fable 5): implementation planning, Flutter code generation,
  the simulation/alert state-machine design, unit tests, debugging (it caught a
  real bug — `latlong2`'s `Distance()` rounds to whole kilometers by default,
  which corrupted the route geometry — via the unit tests), and an
  emulator-driven visual polish pass using screenshots.
- **ChatGPT**: product/UX discussion and engineering decision review.

All generated code was reviewed; the architecture (Provider, feature-first,
derived-state simulation) was a deliberate decision, not a default.

## What I would improve with another 1–2 days

- Real-time driver location over WebSocket/MQTT, replacing the mock timeline
  behind the same provider interface
- Push safety notifications (FCM) with a backend-triggered SMS fallback
- Road-snapped routing (OSRM/Google Directions) instead of a hand-drawn polyline
- Camera follow-driver mode with smart bounds, dark map style
- Trip history and a per-trip safety-event timeline
- Widget/golden tests for alert and SOS states; integration test for the demo flow
- Accessibility pass (semantics, contrast, large-font layouts) and broader
  device testing
- Crash reporting + analytics
