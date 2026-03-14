import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../router/route_names.dart';
import '../providers/booking_provider.dart';
import '../data/schedule_model.dart';

class ScheduleListScreen extends ConsumerWidget {
  final String from, to, date;
  const ScheduleListScreen({super.key, required this.from, required this.to, required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleProvider(
      ScheduleSearchParams(from: from, to: to, date: date),
    ));

    return Scaffold(
      appBar: AppBar(title: Text('$from → $to')),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(icon: Icons.error_outline, title: 'Failed to load schedules', subtitle: e.toString()),
        data: (schedules) => schedules.isEmpty
            ? const EmptyStateWidget(icon: Icons.bus_alert, title: AppStrings.noSchedules)
            : ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: schedules.length,
                itemBuilder: (_, i) => _ScheduleCard(schedule: schedules[i]),
              ),
      ),
    );
  }
}

class _ScheduleCard extends ConsumerWidget {
  final ScheduleModel schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        onTap: () {
          ref.read(bookingProvider.notifier).selectSchedule(schedule.scheduleId);
          context.goNamed(RouteNames.scheduleDetail, pathParameters: {'id': schedule.scheduleId});
        },
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(DateFormatter.formatTime(schedule.departureTime), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: schedule.busClass == 'AC' ? const Color(0xFFDBEAFE) : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(schedule.busClass ?? 'NonAC', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: AppDimensions.xs),
            Text('${schedule.availableSeats} seats available', style: const TextStyle(color: Colors.green)),
            if (schedule.delayMinutes > 0)
              Text(DateFormatter.formatDelay(schedule.delayMinutes), style: const TextStyle(color: Colors.orange)),
          ]),
        ),
      ),
    );
  }
}
