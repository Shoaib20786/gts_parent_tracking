import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';
import 'sos_confirmation_sheet.dart';

/// Persistent emergency action pinned above the scrolling content. Tapping it
/// never fires the SOS directly — it opens the confirmation sheet.
class SosButton extends StatelessWidget {
  const SosButton({super.key});

  @override
  Widget build(BuildContext context) {
    final raised =
        context.watch<ActiveTripProvider>().sosState == SosState.raised;

    if (raised) {
      // Success state stays visible for the rest of the trip; tapping re-opens
      // the sheet's summary of what happened.
      return _SosBar(
        color: AppColors.successSoft,
        border: AppColors.successBorder,
        onTap: () => SosConfirmationSheet.show(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded,
                size: 20, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'SOS raised · Safety team notified',
              style: AppTextStyles.button.copyWith(color: AppColors.success),
            ),
          ],
        ),
      );
    }

    return _SosBar(
      color: AppColors.danger,
      onTap: () => SosConfirmationSheet.show(context),
      shadow: const BoxShadow(
        color: Color(0x4DDC2626),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sos_rounded, size: 22, color: AppColors.textOnPrimary),
          const SizedBox(width: 8),
          Text('Emergency SOS', style: AppTextStyles.button),
        ],
      ),
    );
  }
}

class _SosBar extends StatelessWidget {
  const _SosBar({
    required this.color,
    required this.onTap,
    required this.child,
    this.border,
    this.shadow,
  });

  final Color color;
  final Color? border;
  final BoxShadow? shadow;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [if (shadow != null) shadow!],
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        shape: border == null
            ? null
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: border!),
              ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(height: 56, child: Center(child: child)),
        ),
      ),
    );
  }
}
