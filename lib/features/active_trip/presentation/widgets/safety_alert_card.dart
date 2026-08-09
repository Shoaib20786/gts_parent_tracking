import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/safety_alert.dart';

/// A safety condition in plain parent language. Red for overspeed, amber for a
/// lost location, green once the condition has cleared.
class SafetyAlertCard extends StatelessWidget {
  const SafetyAlertCard({super.key, required this.alert});

  final SafetyAlert alert;

  @override
  Widget build(BuildContext context) {
    final (Color color, Color background, Color border, IconData icon) =
        switch ((alert.type, alert.resolved)) {
      (_, true) => (
          AppColors.success,
          AppColors.successSoft,
          AppColors.successBorder,
          Icons.check_rounded
        ),
      (SafetyAlertType.overspeed, _) => (
          AppColors.danger,
          AppColors.dangerSoft,
          AppColors.dangerBorder,
          Icons.speed_rounded
        ),
      (SafetyAlertType.locationLost, _) => (
          AppColors.warning,
          AppColors.warningSoft,
          AppColors.warningBorder,
          Icons.location_off_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: AppColors.textOnPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.resolved ? 'RESOLVED' : 'SAFETY ALERT',
                  style: AppTextStyles.overline.copyWith(color: color),
                ),
                const SizedBox(height: 3),
                Text(alert.headline, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                Text(alert.detail, style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
