import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/booking_provider.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(bookingHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.myBookings)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(icon: Icons.error_outline, title: 'Failed to load bookings'),
        data: (bookings) => bookings.isEmpty
            ? const EmptyStateWidget(icon: Icons.receipt_long_outlined, title: AppStrings.noBookings, subtitle: 'Your confirmed bookings will appear here')
            : ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.md),
                itemCount: bookings.length,
                itemBuilder: (_, i) {
                  final b = bookings[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppDimensions.sm),
                    child: ListTile(
                      leading: const Icon(Icons.directions_bus_outlined, color: Color(0xFF1E6FFF)),
                      title: Text('${b.fromStop} → ${b.toStop}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('Seat ${b.seatNo} • ${DateFormatter.formatDate(b.bookedAt)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(b.fare), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E6FFF))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: b.status == 'confirmed' ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(b.status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
