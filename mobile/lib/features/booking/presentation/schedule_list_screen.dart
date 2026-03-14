import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/ridesync_app_bar.dart';

/// Schedule List / Search screen — Figma "Search" frame.
class ScheduleListScreen extends ConsumerStatefulWidget {
  const ScheduleListScreen({super.key});
  @override
  ConsumerState<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends ConsumerState<ScheduleListScreen> {
  String _from = '';
  String _to   = '';
  DateTime _date = DateTime.now();
  int _passengers = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Search form header ──────────────────────────────────────────
          _buildSearchForm(),

          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchForm() {
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back + Title
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text('Find a Bus', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 20),
              // From / To with swap
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _StopField(label: 'From', hint: 'Departure stop', value: _from, onChanged: (v) => setState(() => _from = v)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border)),
                          GestureDetector(
                            onTap: () => setState(() { final tmp = _from; _from = _to; _to = tmp; }),
                            child: Container(
                              width: 32, height: 32,
                              margin: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(Icons.swap_vert_rounded, color: AppColors.primary, size: 18),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                    ),
                    _StopField(label: 'To', hint: 'Arrival stop', value: _to, onChanged: (v) => setState(() => _to = v)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Date + Passengers row
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: '${_date.day}/${_date.month}/${_date.year}',
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 60)),
                          builder: (ctx, child) => Theme(
                            data: ThemeData(colorScheme: ColorScheme.light(primary: AppColors.primary)),
                            child: child!,
                          ),
                        );
                        if (picked != null) setState(() => _date = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: '$_passengers Passenger${_passengers > 1 ? 's' : ''}',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search_rounded, size: 20),
                  label: const Text('Search Buses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    final schedules = [
      _ScheduleInfo(from: 'Downtown', to: 'North Station', departure: '09:30 AM', arrival: '10:15 AM', busClass: 'AC', seats: 14, fare: 'LKR 150', routeNo: '47'),
      _ScheduleInfo(from: 'Downtown', to: 'North Station', departure: '11:00 AM', arrival: '11:50 AM', busClass: 'NonAC', seats: 5, fare: 'LKR 100', routeNo: '47'),
      _ScheduleInfo(from: 'Downtown', to: 'North Station', departure: '01:30 PM', arrival: '02:20 PM', busClass: 'AC', seats: 0, fare: 'LKR 150', routeNo: '47'),
      _ScheduleInfo(from: 'Downtown', to: 'North Station', departure: '04:00 PM', arrival: '04:45 PM', busClass: 'NonAC', seats: 22, fare: 'LKR 100', routeNo: '47'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${schedules.length} buses found', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textTitle)),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_rounded, size: 16),
              label: const Text('Filter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...schedules.map((s) => _ScheduleCard(data: s)),
      ],
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────
class _ScheduleInfo {
  final String from, to, departure, arrival, busClass, fare, routeNo;
  final int seats;
  const _ScheduleInfo({required this.from, required this.to, required this.departure, required this.arrival, required this.busClass, required this.seats, required this.fare, required this.routeNo});
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleInfo data;
  const _ScheduleCard({required this.data});
  @override
  Widget build(BuildContext context) {
    final isFull = data.seats == 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(data.departure, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textSecondary),
                        ),
                        Text(data.arrival, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${data.from} → ${data.to}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(data.fare, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const Text('per seat', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              _MetaBadge(icon: Icons.directions_bus_rounded, label: 'Route ${data.routeNo}'),
              const SizedBox(width: 8),
              _MetaBadge(
                icon: data.busClass == 'AC' ? Icons.ac_unit_rounded : Icons.air_outlined,
                label: data.busClass,
                color: data.busClass == 'AC' ? const Color(0xFF3B82F6) : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              _MetaBadge(
                icon: Icons.event_seat_rounded,
                label: isFull ? 'Full' : '${data.seats} seats',
                color: isFull ? AppColors.error : AppColors.success,
              ),
              const Spacer(),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: isFull ? null : () => Navigator.of(context).pushNamed('/seat-picker'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFull ? AppColors.progressTrack : AppColors.primary,
                    foregroundColor: isFull ? AppColors.textDisabled : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  child: Text(isFull ? 'Full' : 'Book Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon; final String label; final Color? color;
  const _MetaBadge({required this.icon, required this.label, this.color});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color ?? AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color ?? AppColors.textSecondary)),
    ],
  );
}

class _StopField extends StatelessWidget {
  final String label, hint, value;
  final ValueChanged<String> onChanged;
  const _StopField({required this.label, required this.hint, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, width: 32)),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ],
  );
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _InfoChip({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
        ],
      ),
    ),
  );
}
