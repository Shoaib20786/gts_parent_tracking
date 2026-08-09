import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/safety_alert.dart';
import '../../provider/active_trip_provider.dart';
import 'demo_controls_sheet.dart';

/// Brand row + the one-line answer a parent needs first:
/// who is travelling, where to, and whether everything is okay.
class TripHeader extends StatelessWidget {
  const TripHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveTripProvider>();
    final trip = provider.trip;
    final arrived = provider.status == TripStatus.arrived;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.directions_bus_rounded,
                  size: 20, color: AppColors.textOnPrimary),
            ),
            const SizedBox(width: 10),
            Text('GTS', style: AppTextStyles.h3.copyWith(letterSpacing: 2)),
            const Spacer(),
            const _StatusPill(),
            // Reviewer-facing scenario triggers, deliberately understated.
            IconButton(
              onPressed: () => DemoControlsSheet.show(context),
              icon: const Icon(Icons.tune_rounded),
              iconSize: 20,
              color: AppColors.textTertiary,
              visualDensity: VisualDensity.compact,
              tooltip: 'Demo controls',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          arrived
              ? '${trip.childName} has arrived home'
              : '${trip.childName} is on the way home',
          style: AppTextStyles.h1,
        ),
        const SizedBox(height: 4),
        Text(
          arrived
              ? 'Dropped off safely at ${trip.destinationLabel}'
              : 'Picked up from ${trip.schoolName} · ${trip.pickupTimeLabel}',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

/// Trip status at a glance. An unresolved safety alert takes over the pill so
/// the very top of the screen never says "all good" while something is wrong.
class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveTripProvider>();
    final alert = provider.activeAlert;

    final (Color color, Color background, String label) = switch (alert) {
      SafetyAlert(resolved: false, type: SafetyAlertType.overspeed) => (
          AppColors.danger,
          AppColors.dangerSoft,
          'Safety alert'
        ),
      SafetyAlert(resolved: false, type: SafetyAlertType.locationLost) => (
          AppColors.warning,
          AppColors.warningSoft,
          'Safety alert'
        ),
      _ when provider.status == TripStatus.arrived => (
          AppColors.success,
          AppColors.successSoft,
          TripStatus.arrived.label
        ),
      _ => (AppColors.primary, AppColors.primarySoft, provider.status.label),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
