import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';

/// Reviewer-only scenario triggers so the demo never has to wait for the
/// scripted timeline. Not part of the parent experience.
class DemoControlsSheet extends StatelessWidget {
  const DemoControlsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      builder: (_) => const DemoControlsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActiveTripProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demo controls', style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(
                    'Deterministic scenario triggers for reviewing the prototype.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _DemoTile(
              icon: provider.isPaused
                  ? Icons.play_circle_rounded
                  : Icons.pause_circle_rounded,
              label: provider.isPaused ? 'Resume simulation' : 'Pause simulation',
              onTap: provider.togglePause,
            ),
            _DemoTile(
              icon: Icons.speed_rounded,
              label: 'Trigger overspeeding',
              onTap: provider.jumpToOverspeed,
            ),
            _DemoTile(
              icon: Icons.location_off_rounded,
              label: 'Trigger lost location',
              onTap: provider.jumpToLocationLoss,
            ),
            _DemoTile(
              icon: Icons.flag_rounded,
              label: 'Jump near arrival',
              onTap: provider.jumpNearArrival,
            ),
            _DemoTile(
              icon: Icons.replay_rounded,
              label: 'Restart trip',
              onTap: provider.restartTrip,
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
      },
      leading: Icon(icon, size: 22, color: AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      visualDensity: VisualDensity.compact,
    );
  }
}
