import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';

enum _Stage { confirm, raising, success }

/// SOS flow: explicit confirmation -> raising -> success. The extra step is
/// deliberate — an emergency action must be hard to trigger accidentally.
class SosConfirmationSheet extends StatefulWidget {
  const SosConfirmationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SosConfirmationSheet(),
    );
  }

  @override
  State<SosConfirmationSheet> createState() => _SosConfirmationSheetState();
}

class _SosConfirmationSheetState extends State<SosConfirmationSheet> {
  late _Stage _stage;

  @override
  void initState() {
    super.initState();
    // Re-opened after a previous SOS: go straight to the summary.
    _stage = context.read<ActiveTripProvider>().sosState == SosState.raised
        ? _Stage.success
        : _Stage.confirm;
  }

  Future<void> _raise() async {
    setState(() => _stage = _Stage.raising);
    await context.read<ActiveTripProvider>().raiseSos();
    if (mounted) setState(() => _stage = _Stage.success);
  }

  @override
  Widget build(BuildContext context) {
    final childName = context.read<ActiveTripProvider>().trip.childName;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Column(
            key: ValueKey(_stage),
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
              const SizedBox(height: 24),
              ...switch (_stage) {
                _Stage.confirm => _confirmContent(childName),
                _Stage.raising => _raisingContent(),
                _Stage.success => _successContent(childName),
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _confirmContent(String childName) => [
        const _SheetIcon(color: AppColors.danger, background: AppColors.dangerSoft, icon: Icons.sos_rounded),
        const SizedBox(height: 18),
        Text('Raise an SOS alert?',
            style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'This immediately alerts the GTS safety team and shares '
          "$childName's live trip with them. Use it if you're worried "
          "about $childName's safety.",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _raise,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Yes, raise SOS', style: AppTextStyles.button),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text('Cancel',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
        ),
      ];

  List<Widget> _raisingContent() => [
        const SizedBox(height: 10),
        const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
                strokeWidth: 3, color: AppColors.danger),
          ),
        ),
        const SizedBox(height: 20),
        Text('Raising SOS…', style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('Contacting the GTS safety team',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
      ];

  List<Widget> _successContent(String childName) => [
        const _SheetIcon(color: AppColors.success, background: AppColors.successSoft, icon: Icons.check_rounded),
        const SizedBox(height: 18),
        Text('SOS alert raised',
            style: AppTextStyles.h2, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'The GTS safety team has been notified and will contact you right '
          "away. Keep this screen open to follow $childName's trip.",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Done', style: AppTextStyles.button),
        ),
      ];
}

class _SheetIcon extends StatelessWidget {
  const _SheetIcon({required this.color, required this.background, required this.icon});

  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }
}
