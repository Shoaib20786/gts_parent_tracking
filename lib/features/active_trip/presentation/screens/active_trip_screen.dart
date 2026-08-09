import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../provider/active_trip_provider.dart';
import '../widgets/safety_alert_card.dart';
import '../widgets/sos_button.dart';
import '../widgets/trip_header.dart';
import '../widgets/trip_map.dart';
import '../widgets/trip_metrics.dart';
import '../widgets/trip_status_card.dart';

/// The single screen of the prototype: loading -> (error) -> active trip.
class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loadState =
        context.select<ActiveTripProvider, TripLoadState>((p) => p.loadState);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: switch (loadState) {
          TripLoadState.loading => const _LoadingView(key: ValueKey('loading')),
          TripLoadState.error => const _ErrorView(key: ValueKey('error')),
          TripLoadState.ready => const _TripContent(key: ValueKey('trip')),
        },
      ),
    );
  }
}

class _TripContent extends StatelessWidget {
  const _TripContent({super.key});

  @override
  Widget build(BuildContext context) {
    final alert = context.watch<ActiveTripProvider>().activeAlert;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 10, 12, 0),
                child: TripHeader(),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 120 + bottomInset),
                  children: [
                    const TripMap(),
                    const SizedBox(height: 16),
                    // The alert slides in above the trip details so a safety
                    // issue interrupts the normal hierarchy.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: alert == null
                            ? const SizedBox(width: double.infinity)
                            : Padding(
                                key: ValueKey('${alert.type}-${alert.resolved}'),
                                padding: const EdgeInsets.only(bottom: 16),
                                child: SafetyAlertCard(alert: alert),
                              ),
                      ),
                    ),
                    const TripMetrics(),
                    const SizedBox(height: 16),
                    const TripStatusCard(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomInset + 16,
            child: const SosButton(),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.directions_bus_rounded,
                size: 32, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 18),
          Text('GTS', style: AppTextStyles.h1.copyWith(letterSpacing: 3)),
          const SizedBox(height: 4),
          Text('Live trip tracking', style: AppTextStyles.caption),
          const SizedBox(height: 32),
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primary),
          ),
          const SizedBox(height: 14),
          Text("Finding your child's trip…", style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// The mock load never fails, but a real fetch would — keep the recovery
/// path in place.
class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text("We couldn't load the trip", style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text('Please check your connection and try again.',
                style: AppTextStyles.caption, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<ActiveTripProvider>().init(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Try again', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
