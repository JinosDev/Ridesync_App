import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Booking Success screen — Figma "Acc..." success/QR frame.
/// Shows QR e-ticket.
class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Success icon
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
                    ),
                    const SizedBox(height: 16),
                    const Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    const Text('Your seat has been reserved successfully.', style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                    const SizedBox(height: 28),

                    // Ticket card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 20, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          // Orange header band
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Route 47', style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600)),
                                    SizedBox(height: 4),
                                    Text('Downtown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                                    Text('→ North Station', style: TextStyle(fontSize: 13, color: Colors.white70)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('AC Class', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          // Notch divider
                          Row(
                            children: [
                              Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)))),
                              Expanded(child: DashedLine()),
                              Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)))),
                            ],
                          ),

                          // Details
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: const [
                                    _TicketDetail(label: 'Date',      value: '15 Mar 2025'),
                                    _TicketDetail(label: 'Departure', value: '09:30 AM'),
                                    _TicketDetail(label: 'Seat',      value: 'Seat 3'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // QR placeholder
                                Container(
                                  width: 160, height: 160,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.border, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_2_rounded, size: 120, color: AppColors.textPrimary),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text('TKT-2025-03-15-A3F7', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1)),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Total Paid', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                                    Text('LKR 150', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download E-Ticket'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  final String label, value;
  const _TicketDetail({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ],
  );
}

class DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 20,
    child: CustomPaint(painter: _DashedPainter()),
  );
}

class _DashedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.border..strokeWidth = 1.5;
    const dashW = 6.0; const gap = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(x + dashW, size.height / 2), paint);
      x += dashW + gap;
    }
  }
  @override bool shouldRepaint(_) => false;
}
