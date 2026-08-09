import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/safety_alert.dart';
import '../../data/mock_trip_data.dart';
import '../../provider/active_trip_provider.dart';

/// Live route view: OpenStreetMap tiles, the travelled/remaining route split,
/// school + home markers, and the animated driver marker.
class TripMap extends StatefulWidget {
  const TripMap({super.key});

  @override
  State<TripMap> createState() => _TripMapState();
}

class _TripMapState extends State<TripMap> {
  final MapController _mapController = MapController();

  static final CameraFit _routeFit = CameraFit.coordinates(
    coordinates: MockTripData.routePoints,
    padding: const EdgeInsets.fromLTRB(44, 68, 44, 52),
  );

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveTripProvider>();
    final height =
        (MediaQuery.sizeOf(context).height * 0.33).clamp(240.0, 340.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Animating `progress` (rather than jumping tick-to-tick) is what
          // makes the driver glide along the route between simulation updates.
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: provider.progress),
              duration: const Duration(milliseconds: 2200),
              curve: Curves.easeInOutCubic,
              builder: (context, t, _) {
                final route = MockTripData.route;
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: _routeFit,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    backgroundColor: AppColors.mapBackground,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.gts.gts_parent_tracking',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route.remainingPath(t),
                          color: AppColors.routeRemaining,
                          strokeWidth: 5,
                          // Not const: StrokePattern.dashed's assert reads
                          // segments.length, which const-eval doesn't allow.
                          pattern: StrokePattern.dashed(segments: const [16.0, 12.0]),
                          borderColor: AppColors.cardBackground,
                          borderStrokeWidth: 1.5,
                          strokeCap: StrokeCap.round,
                        ),
                        Polyline(
                          points: route.travelledPath(t),
                          color: AppColors.routeTravelled,
                          strokeWidth: 6,
                          borderColor: AppColors.cardBackground,
                          borderStrokeWidth: 2,
                          strokeCap: StrokeCap.round,
                          strokeJoin: StrokeJoin.round,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: route.start,
                          width: 130,
                          height: 58,
                          child: const _PlaceMarker(
                              icon: Icons.school_rounded, label: 'School'),
                        ),
                        Marker(
                          point: route.end,
                          width: 130,
                          height: 58,
                          child: const _PlaceMarker(
                              icon: Icons.home_rounded, label: 'Home'),
                        ),
                        Marker(
                          point: route.positionAt(t),
                          width: 72,
                          height: 72,
                          child: _DriverMarker(alert: provider.activeAlert),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(top: 14, left: 14, child: _LiveChip(provider: provider)),
          Positioned(
            right: 12,
            bottom: 34,
            child: _RecenterButton(
              onPressed: () => _mapController.fitCamera(_routeFit),
            ),
          ),
          // OSM requires attribution; keep it honest but compact.
          Positioned(
            right: 12,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xB3FFFFFF),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '© OpenStreetMap',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "LIVE" indicator that degrades honestly when the signal is lost.
class _LiveChip extends StatelessWidget {
  const _LiveChip({required this.provider});

  final ActiveTripProvider provider;

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = provider.hasArrived
        ? (AppColors.success, 'ARRIVED')
        : provider.locationIsStale
            ? (AppColors.warning, 'NO SIGNAL')
            : (AppColors.liveDot, 'LIVE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.overline.copyWith(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: AppColors.cardShadow,
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.center_focus_strong_rounded),
        iconSize: 20,
        color: AppColors.textSecondary,
        tooltip: 'Recenter route',
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            boxShadow: const [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, 3)),
            ],
          ),
          child: Text(label,
              style: AppTextStyles.labelMedium.copyWith(fontSize: 10)),
        ),
      ],
    );
  }
}

/// The child's vehicle. The pulsing ring picks up the active alert color so
/// the marker itself communicates the safety state.
class _DriverMarker extends StatefulWidget {
  const _DriverMarker({required this.alert});

  final SafetyAlert? alert;

  @override
  State<_DriverMarker> createState() => _DriverMarkerState();
}

class _DriverMarkerState extends State<_DriverMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Color get _color => switch (widget.alert) {
        SafetyAlert(resolved: false, type: SafetyAlertType.overspeed) =>
          AppColors.danger,
        SafetyAlert(resolved: false, type: SafetyAlertType.locationLost) =>
          AppColors.warning,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final v = Curves.easeOut.transform(_pulse.value);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 34 + 34 * v,
              height: 34 + 34 * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _color.withValues(alpha: 0.28 * (1 - v)),
              ),
            ),
            child!,
          ],
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.cardBackground, width: 3),
          boxShadow: const [
            BoxShadow(color: AppColors.cardShadow, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.directions_car_rounded,
            size: 19, color: AppColors.textOnPrimary),
      ),
    );
  }
}
