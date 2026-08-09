import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';

/// Who is driving the child: identity, trust signals (rating, trip count) and
/// the vehicle to look for at the kerb.
class TripStatusCard extends StatelessWidget {
  const TripStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = context.watch<ActiveTripProvider>().trip;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: AppColors.cardShadow, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              trip.driverInitials,
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.driverName, style: AppTextStyles.h3),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 15, color: AppColors.ratingStar),
                    const SizedBox(width: 3),
                    Text('${trip.driverRating}',
                        style: AppTextStyles.labelMedium),
                    Text(' · ${trip.driverTripCount} trips',
                        style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${trip.vehicle} · ${trip.plate}',
                    style: AppTextStyles.caption,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: AppColors.primarySoft,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Text('Calling is not available in this prototype.'),
                  ));
              },
              icon: const Icon(Icons.phone_rounded),
              color: AppColors.primary,
              iconSize: 20,
              tooltip: 'Call driver',
            ),
          ),
        ],
      ),
    );
  }
}
