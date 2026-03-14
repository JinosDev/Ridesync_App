import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../router/route_names.dart';
import '../providers/booking_provider.dart';

class ScheduleDetailScreen extends ConsumerWidget {
  final String scheduleId;
  const ScheduleDetailScreen({super.key, required this.scheduleId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleDetailProvider(scheduleId));
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Details')),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (schedule) => Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${schedule.startPoint} → ${schedule.endPoint}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppDimensions.md),
              Text('Class: ${schedule.busClass}'),
              Text('Available Seats: ${schedule.availableSeats}'),
              const Spacer(),
              RideSyncButton(
                label: 'Select Seat',
                onPressed: () => context.goNamed(RouteNames.fareEstimator),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
