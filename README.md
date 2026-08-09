# GTS — Parent Trip Tracking Prototype

A focused Flutter prototype of the GTS (Go To Shore) parent experience: a parent
watching their child's live school trip, receiving plain-language safety alerts,
and raising an SOS with an explicit confirmation step.

| Live trip | Overspeed alert | Location lost | SOS confirm | SOS raised |
| --- | --- | --- | --- | --- |
| ![Live trip](docs/screenshots/live_trip.png) | ![Overspeed](docs/screenshots/overspeed_alert.png) | ![Location lost](docs/screenshots/location_lost_alert.png) | ![SOS confirm](docs/screenshots/sos_confirm.png) | ![SOS raised](docs/screenshots/sos_success.png) |

## Features

- Active child journey with child, driver (name, rating, trip count), vehicle + plate, school and destination
- Real map (OpenStreetMap via `flutter_map`) with the route split into travelled/remaining, school + home markers, and an animated driver marker that glides between location updates
- Live ETA, current speed, distance to destination, and trip status — all recomputed every simulation tick
- Safety alert: **overspeeding** (red, with current speed vs. safe limit)
- Safety alert: **location stopped/unavailable** (amber, with time since last update, "NO SIGNAL" map chip)
- Both alerts show a brief green **resolved** state when the condition clears
- **SOS flow**: tap → confirmation sheet → raising → success state, with a persistent "SOS raised" bar afterwards
- Loading and error/retry states for the initial trip fetch
- Demo controls (tune icon, top right): pause/resume, trigger overspeed, trigger lost location, jump near arrival, restart

## Run

```bash
flutter pub get
flutter run
```

Requires internet access for OpenStreetMap tiles (everything else is local).
Built and verified with Flutter 3.35.5 / Dart 3.9.2 on Android.

## Test / build

```bash
flutter test                     # provider + route geometry unit tests
flutter build apk --release      # build/app/outputs/flutter-apk/app-release.apk
```

## How it works

- `ActiveTripProvider` owns all state. Every displayed value (position, speed,
  distance, ETA, status, alerts) is **derived purely from an index into a
  deterministic mock timeline**, advanced by a periodic `Timer`. The demo
  controls and the unit tests drive the exact same seek path as the timer, so
  the demo plays out identically on every run and the logic is trivially
  testable without timers.
- The location-lost alert is not scripted directly: the provider detects that
  the position hasn't changed for N consecutive ticks — the same rule a real
  backend would apply.
- The map animates a single `progress` value (0..1 along the route polyline);
  `RouteGeometry` resolves it to a lat/lng and splits the polyline into
  travelled/remaining halves.
- Widgets are presentational; theme tokens (`AppColors`, `AppTextStyles`) are
  the single source of truth for colors and type.

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
derived-state simulation) was a deliberate human decision, not a default.

## What I would improve with another 1–2 days

- Real-time driver location over WebSocket/MQTT with a backend, replacing the
  mock timeline behind the same provider interface
- Push safety notifications (FCM) with a backend-triggered SMS fallback for
  critical alerts
- Road-snapped routing (OSRM/Google Directions) instead of a hand-drawn polyline
- Camera follow-driver mode with smart bounds, plus dark map style
- Trip history and a safety-event timeline per trip
- Widget/golden tests for the alert and SOS states, integration test for the
  demo flow
- Accessibility pass (semantics, contrast, large-font layouts) and broader
  device testing
- Crash reporting + analytics
