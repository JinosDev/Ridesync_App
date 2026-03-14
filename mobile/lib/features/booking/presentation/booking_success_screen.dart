import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../router/route_names.dart';
import '../providers/booking_provider.dart';

class BookingSuccessScreen extends ConsumerWidget {
  const BookingSuccessScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider).confirmedBooking;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 80),
            const SizedBox(height: AppDimensions.md),
            Text('Booking Confirmed!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            if (booking != null) ...[
              const SizedBox(height: AppDimensions.lg),
              Center(
                child: QrImageView(data: booking.bookingId, size: 180),
              ),
              const SizedBox(height: AppDimensions.md),
              Text('Seat: ${booking.seatNo}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
              Text('Booking ID: ${booking.bookingId}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
            const Spacer(),
            RideSyncButton(label: 'View My Bookings', onPressed: () {
              ref.read(bookingProvider.notifier).reset();
              context.goNamed(RouteNames.myBookings);
            }),
            const SizedBox(height: AppDimensions.sm),
            RideSyncButton(label: 'Back to Home', isOutlined: true, onPressed: () {
              ref.read(bookingProvider.notifier).reset();
              context.goNamed(RouteNames.home);
            }),
          ],
        ),
      ),
    );
  }
}
