import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../router/route_names.dart';
import '../../booking/providers/booking_provider.dart';

class SeatPickerScreen extends ConsumerWidget {
  const SeatPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedScheduleId = ref.watch(bookingProvider).selectedScheduleId;

    if (selectedScheduleId == null) {
      return const Scaffold(body: Center(child: Text('No schedule selected')));
    }

    final scheduleAsync = ref.watch(scheduleDetailProvider(selectedScheduleId));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Seat')),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (schedule) {
          final seatMap = schedule.seatMap;
          final seats = seatMap.keys.toList()..sort();
          final selectedSeat = ref.watch(bookingProvider).selectedSeatNo;

          return Column(
            children: [
              // Legend
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Row(children: [
                  _Legend(color: AppColors.seatAvailable, label: 'Available'),
                  const SizedBox(width: AppDimensions.md),
                  _Legend(color: AppColors.seatBooked,    label: 'Booked'),
                  const SizedBox(width: AppDimensions.md),
                  _Legend(color: AppColors.seatSelected,  label: 'Selected'),
                ]),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: AppDimensions.seatGridColumns,
                    crossAxisSpacing: AppDimensions.sm,
                    mainAxisSpacing: AppDimensions.sm,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: seats.length,
                  itemBuilder: (_, i) {
                    final seatNo  = seats[i];
                    final isBooked   = seatMap[seatNo] != null;
                    final isSelected = seatNo == selectedSeat;
                    final color = isSelected ? AppColors.seatSelected : isBooked ? AppColors.seatBooked : AppColors.seatAvailable;
                    return GestureDetector(
                      onTap: isBooked ? null : () => ref.read(bookingProvider.notifier).selectSeat(seatNo),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Center(child: Text(seatNo, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400))),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: RideSyncButton(
                  label: selectedSeat != null ? 'Confirm Seat $selectedSeat' : 'Select a Seat',
                  onPressed: selectedSeat != null ? () => context.goNamed(RouteNames.bookingConfirm) : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 16, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3), border: Border.all(color: AppColors.border))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}
