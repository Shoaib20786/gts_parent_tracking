import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';

/// The journey numbers: a hero ETA, compact speed/distance stats, and a
/// school-to-home progress bar.
class TripMetrics extends StatelessWidget {
  const TripMetrics({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveTripProvider>();
    final arrived = provider.hasArrived;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      arrived ? 'TRIP COMPLETE' : 'ARRIVING IN',
                      style: AppTextStyles.overline
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    if (arrived)
                      Text('Arrived',
                          style: AppTextStyles.display
                              .copyWith(color: AppColors.success, fontSize: 32))
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('${provider.etaMinutes}',
                              style: AppTextStyles.display),
                          const SizedBox(width: 4),
                          Text('min',
                              style: AppTextStyles.h2
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      arrived
                          ? '${provider.trip.childName} was dropped off safely'
                          : 'Estimated ${provider.arrivalClock}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Stat(
                    icon: Icons.speed_rounded,
                    value: '${provider.speedKmh.round()} km/h',
                    label: 'Current speed',
                  ),
                  const SizedBox(height: 14),
                  _Stat(
                    icon: Icons.route_rounded,
                    value: '${provider.remainingKm.toStringAsFixed(1)} km',
                    label: 'To destination',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          TweenAnimationBuilder<double>(
            tween: Tween(end: provider.progress),
            duration: const Duration(milliseconds: 2200),
            curve: Curves.easeInOutCubic,
            builder: (context, t, _) => ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: t,
                minHeight: 6,
                color: arrived ? AppColors.success : AppColors.primary,
                backgroundColor: AppColors.scaffoldBackground,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(provider.trip.schoolName,
                    style: AppTextStyles.caption, overflow: TextOverflow.ellipsis),
              ),
              Text(provider.trip.destinationLabel, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.labelLarge),
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(fontSize: 11, color: AppColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}
