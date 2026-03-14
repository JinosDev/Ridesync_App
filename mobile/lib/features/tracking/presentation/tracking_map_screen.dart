import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/tracking_provider.dart';

/// Live Tracking Map screen — Figma "Live..." frame.
/// Shows real-time bus location on a placeholder map.
class TrackingMapScreenV2 extends ConsumerWidget {
  final String scheduleId;
  const TrackingMapScreenV2({super.key, required this.scheduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider(scheduleId));

    return Scaffold(
      backgroundColor: const Color(0xFF1A2332),
      body: Stack(
        children: [
          // ── Map placeholder (swap with GoogleMap in production) ─────────
          _MapPlaceholder(),

          // ── Top bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.directions_bus_rounded, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text('Route 47 — Downtown to North Station', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Live indicator top-right ────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 68, right: 16),
                child: _LiveBadge(),
              ),
            ),
          ),

          // ── Bottom info panel ───────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _TrackingBottomPanel(tracking: tracking),
          ),
        ],
      ),
    );
  }
}

// ── Map placeholder ─────────────────────────────────────────────────────────────
class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
        ),
      ),
      child: CustomPaint(painter: _GridPainter()),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += 40) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override bool shouldRepaint(_) => false;
}

// ── Live badge ─────────────────────────────────────────────────────────────────
class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gpsActive.withOpacity(0.15 + _ctrl.value * 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gpsActive.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.gpsActive, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('LIVE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1)),
        ],
      ),
    ),
  );
}

// ── Bottom info panel ──────────────────────────────────────────────────────────
class _TrackingBottomPanel extends StatelessWidget {
  final AsyncValue<dynamic> tracking;
  const _TrackingBottomPanel({required this.tracking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2332),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),

          // ETA row
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.timer_rounded,
                  label: 'ETA',
                  value: '8 min',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.straighten_rounded,
                  label: 'Distance',
                  value: '4.2 km',
                  color: const Color(0xFF60A5FA),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.speed_rounded,
                  label: 'Speed',
                  value: '42 km/h',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Next stop
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(Icons.place_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Stop', style: TextStyle(fontSize: 11, color: Colors.white54)),
                      SizedBox(height: 2),
                      Text('Central Park Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('3 stops away', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              Icon(Icons.circle, size: 10, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(3)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.6,
                    child: Container(decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.circle, size: 10, color: Colors.white24),
              const SizedBox(width: 6),
              const Text('North Station', style: TextStyle(fontSize: 10, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('60% of route completed', style: TextStyle(fontSize: 10, color: Colors.white38)),

          const SizedBox(height: 16),

          // Stale signal warning (example)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.signal_cellular_off_rounded, color: AppColors.warning, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('GPS last updated 15s ago. Position may not be current.', style: TextStyle(fontSize: 11, color: AppColors.warning))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _InfoTile({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38)),
      ],
    ),
  );
}
