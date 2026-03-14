import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../router/route_names.dart';
import '../providers/trip_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';

class TripDashboardScreen extends ConsumerWidget {
  final String scheduleId;
  const TripDashboardScreen({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);
    final authState = ref.watch(authStateProvider).valueOrNull;
    final busId     = authState?.busId ?? '';

    return Scaffold(
      appBar: AppBar(title: Text('Trip Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GPS status indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(children: [
                  Icon(
                    tripState.isGpsBroadcasting ? Icons.gps_fixed : Icons.gps_off,
                    color: tripState.isGpsBroadcasting ? AppColors.gpsActive : AppColors.gpsInactive,
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    tripState.isGpsBroadcasting ? AppStrings.gpsBroadcasting : AppStrings.gpsInactive,
                    style: TextStyle(
                      color: tripState.isGpsBroadcasting ? AppColors.gpsActive : AppColors.gpsInactive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: AppDimensions.md),

            // Trip actions
            if (tripState.status == TripStatus.idle) ...[
              RideSyncButton(
                label: AppStrings.startTrip,
                icon: Icons.play_arrow_rounded,
                onPressed: () => ref.read(tripProvider.notifier).startTrip(scheduleId, busId),
              ),
            ] else if (tripState.status == TripStatus.active) ...[
              RideSyncButton(
                label: 'View Passengers',
                icon: Icons.people_outline,
                isOutlined: true,
                onPressed: () => context.goNamed(RouteNames.manifest, pathParameters: {'scheduleId': scheduleId}),
              ),
              const SizedBox(height: AppDimensions.sm),
              RideSyncButton(
                label: 'Report Delay',
                icon: Icons.schedule_outlined,
                isOutlined: true,
                onPressed: () => context.goNamed(RouteNames.statusUpdate, pathParameters: {'scheduleId': scheduleId}),
              ),
              const SizedBox(height: AppDimensions.sm),
              RideSyncButton(
                label: AppStrings.endTrip,
                icon: Icons.stop_circle_outlined,
                color: AppColors.error,
                onPressed: () => ref.read(tripProvider.notifier).endTrip(scheduleId),
              ),
            ] else ...[
              const Center(child: Text('Trip Completed ✓', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
            ],
          ],
        ),
      ),
    );
  }
}
