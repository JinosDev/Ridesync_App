import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../router/route_names.dart';
import '../providers/booking_provider.dart';

class BookingConfirmScreen extends ConsumerWidget {
  const BookingConfirmScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.md),
                child: Column(children: [
                  _InfoRow('From',   booking.fromStop  ?? '-'),
                  _InfoRow('To',     booking.toStop    ?? '-'),
                  _InfoRow('Seat',   booking.selectedSeatNo ?? '-'),
                  _InfoRow('Fare',   CurrencyFormatter.format(booking.estimatedFare ?? 0)),
                ]),
              ),
            ),
            const Spacer(),
            RideSyncButton(
              label: 'Pay & Book',
              isLoading: booking.status == BookingStatus.loading,
              onPressed: () async {
                await ref.read(bookingProvider.notifier).confirmBooking();
                if (ref.read(bookingProvider).status == BookingStatus.success) {
                  if (context.mounted) context.goNamed(RouteNames.bookingSuccess);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))],
    ),
  );
}
