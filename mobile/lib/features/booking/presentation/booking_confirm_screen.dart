import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ridesync_app_bar.dart';

/// Booking Confirm screen — Figma "Acc..." (Account/Confirm) frame.
/// Step 3 of 3: shows booking summary before payment.
class BookingConfirmScreenV2 extends StatelessWidget {
  const BookingConfirmScreenV2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RideSyncAppBar(
        title: 'Confirm Booking',
        subtitle: 'Step 3 of 3 — Review & Pay',
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: 1.0,
                backgroundColor: AppColors.progressTrack,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 8,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionCard(children: [
                    _SectionTitle('Trip Details'),
                    _DetailRow(icon: Icons.directions_bus_rounded, label: 'Route', value: 'Route 47 — Downtown to North Station'),
                    _DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: 'Saturday, 15 Mar 2025'),
                    _DetailRow(icon: Icons.access_time_rounded, label: 'Departure', value: '09:30 AM'),
                    _DetailRow(icon: Icons.timer_outlined, label: 'Arrival', value: '10:15 AM (est.)'),
                    _DetailRow(icon: Icons.event_seat_rounded, label: 'Seat', value: 'Seat 3 (Window — AC)'),
                    _DetailRow(icon: Icons.person_outline_rounded, label: 'Passenger', value: 'John Doe'),
                  ]),
                  const SizedBox(height: 16),

                  _SectionCard(children: [
                    _SectionTitle('Fare Breakdown'),
                    _FareRow('Base Fare',                  'LKR 20.00'),
                    _FareRow('Distance (13 km × LKR 5)',   'LKR 65.00'),
                    _FareRow('AC Class (×1.4)',             'LKR 119.00'),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        Text('LKR 150', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _SectionCard(children: [
                    _SectionTitle('Payment Method'),
                    _PaymentOption(icon: Icons.credit_card_outlined, label: 'Card ending in 4242', selected: true),
                    _PaymentOption(icon: Icons.account_balance_wallet_outlined, label: 'RideSync Wallet (LKR 500)', selected: false),
                  ]),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Bottom CTA
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/booking-success'),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Confirm & Pay LKR 150'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
      ],
    ),
  );
}

class _FareRow extends StatelessWidget {
  final String label, value;
  const _FareRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textTitle)),
      ],
    ),
  );
}

class _PaymentOption extends StatelessWidget {
  final IconData icon; final String label; final bool selected;
  const _PaymentOption({required this.icon, required this.label, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: selected ? AppColors.primary.withOpacity(0.06) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
    ),
    child: Row(
      children: [
        Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.textPrimary : AppColors.textSecondary))),
        if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
      ],
    ),
  );
}
