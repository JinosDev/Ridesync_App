import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../router/route_names.dart';
import '../providers/trip_provider.dart';

class OperatorHomeScreen extends ConsumerWidget {
  const OperatorHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(operatorScheduleProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Trips"),
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () => context.goNamed(RouteNames.profile)),
        ],
      ),
      body: schedulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => EmptyStateWidget(icon: Icons.error_outline, title: 'Failed to load schedules'),
        data: (schedules) => schedules.isEmpty
            ? const EmptyStateWidget(icon: Icons.bus_alert, title: 'No schedules today')
            : ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: schedules.length,
                itemBuilder: (_, i) {
                  final s = schedules[i] as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus_outlined, color: Color(0xFF1E6FFF)),
                      title: Text(s['scheduleId'] as String? ?? '-'),
                      subtitle: Text(s['status'] as String? ?? 'scheduled'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.goNamed(RouteNames.tripDashboard, pathParameters: {'scheduleId': s['scheduleId'] as String}),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
