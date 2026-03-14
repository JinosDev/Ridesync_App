import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Seat status model
enum SeatStatus { available, selectedByMe, bookedMale, bookedFemale, disabled }

class SeatData {
  final int number;
  final SeatStatus status;
  const SeatData(this.number, this.status);
}

/// The full Seat Picker screen — matches Figma "Select Seat" design.
/// 2+3 bus arrangement with driver station at the front.
class SeatPickerScreenV2 extends StatefulWidget {
  final String routeName;
  final String scheduleId;
  const SeatPickerScreenV2({
    super.key,
    this.routeName = 'Downtown - North Station',
    required this.scheduleId,
  });

  @override
  State<SeatPickerScreenV2> createState() => _SeatPickerScreenV2State();
}

class _SeatPickerScreenV2State extends State<SeatPickerScreenV2> {
  int? _selectedSeat;

  // Simulate a seat map — replace with provider data in production
  late final List<SeatData> _seats = [
    SeatData(1,  SeatStatus.available),
    SeatData(2,  SeatStatus.bookedMale),
    SeatData(3,  SeatStatus.selectedByMe),
    SeatData(4,  SeatStatus.available),
    SeatData(5,  SeatStatus.available),

    SeatData(6,  SeatStatus.bookedFemale),
    SeatData(7,  SeatStatus.available),
    SeatData(8,  SeatStatus.bookedMale),
    SeatData(9,  SeatStatus.bookedFemale),
    SeatData(10, SeatStatus.available),

    SeatData(11, SeatStatus.available),
    SeatData(12, SeatStatus.available),
    SeatData(13, SeatStatus.selectedByMe),
    SeatData(14, SeatStatus.available),
    SeatData(15, SeatStatus.disabled),

    SeatData(16, SeatStatus.available),
    SeatData(17, SeatStatus.available),
    SeatData(18, SeatStatus.disabled),
    SeatData(19, SeatStatus.available),
    SeatData(20, SeatStatus.available),

    SeatData(21, SeatStatus.available),
    SeatData(22, SeatStatus.bookedMale),
    SeatData(23, SeatStatus.selectedByMe),
    SeatData(24, SeatStatus.available),
    SeatData(25, SeatStatus.available),

    SeatData(26, SeatStatus.bookedFemale),
    SeatData(27, SeatStatus.available),
    SeatData(28, SeatStatus.bookedMale),
    SeatData(29, SeatStatus.bookedFemale),
    SeatData(30, SeatStatus.available),

    SeatData(31, SeatStatus.available),
    SeatData(32, SeatStatus.available),
    SeatData(33, SeatStatus.selectedByMe),
    SeatData(34, SeatStatus.available),
    SeatData(35, SeatStatus.disabled),

    SeatData(36, SeatStatus.available),
    SeatData(37, SeatStatus.available),
    SeatData(38, SeatStatus.disabled),
    SeatData(39, SeatStatus.available),
    SeatData(40, SeatStatus.available),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar ─────────────────────────────────────────────────────
          _SeatAppBar(routeName: widget.routeName),

          // ── Scrollable body ────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Progress bar
                  _buildProgressBar(),
                  const SizedBox(height: 16),

                  // Legend
                  _buildLegend(),
                  const SizedBox(height: 16),

                  // Bus layout card
                  _buildBusCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ─────────────────────────────────────────────────
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Progress bar section ─────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Booking Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textTitle)),
              Text('Step 2 of 3', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: 2 / 3,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SEAT SELECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.6)),
              const Text('Bus Layout: 2+3 Arrangement', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Legend row ────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _LegendChip(label: 'AVAILABLE', bg: AppColors.surface,      border: AppColors.border,         textColor: AppColors.textSecondary),
          _LegendChip(label: 'SELECTED',  bg: AppColors.seatSelected, border: AppColors.seatSelectedBorder, textColor: AppColors.primary),
          _LegendChip(label: 'MALE',      bg: AppColors.seatMale,     border: AppColors.seatMaleBorder,  textColor: AppColors.seatMaleText),
          _LegendChip(label: 'FEMALE',    bg: AppColors.seatFemale,   border: AppColors.seatFemaleBorder, textColor: AppColors.seatFemaleText),
        ],
      ),
    );
  }

  // ── Bus layout card ───────────────────────────────────────────────────────
  Widget _buildBusCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver station header
          _buildDriverStation(),
          const SizedBox(height: 32),

          // Seat rows
          ..._buildSeatRows(),
        ],
      ),
    );
  }

  Widget _buildDriverStation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.steering_wheel_outlined, size: 20, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            const Text('Driver Station', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(4)),
          child: const Text('FRONT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 1)),
        ),
      ],
    );
  }

  /// Splits _seats into rows of 5 (2 | aisle | 3).
  /// Seats per row: [leftA, leftB, null(aisle), rightA, rightB, rightC]
  List<Widget> _buildSeatRows() {
    final rows = <Widget>[];
    final seatsPerRow = 5; // 2 left + 3 right (aisle is visual)
    final totalRows = (_seats.length / seatsPerRow).ceil();

    for (int row = 0; row < totalRows; row++) {
      final rowSeats = _seats.skip(row * seatsPerRow).take(seatsPerRow).toList();
      rows.add(_buildSeatRow(rowSeats));
      if (row < totalRows - 1) rows.add(const SizedBox(height: 16));
    }
    return rows;
  }

  Widget _buildSeatRow(List<SeatData> seats) {
    // 2+3 layout: seats[0], seats[1] | aisle | seats[2], seats[3], seats[4]
    final leftSeats  = seats.length >= 2 ? seats.sublist(0, 2) : seats;
    final rightSeats = seats.length > 2  ? seats.sublist(2)    : <SeatData>[];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left 2 seats
        ...leftSeats.map((s) => _buildSeatTile(s)),
        // Aisle gap
        const SizedBox(width: 12),
        Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
        const SizedBox(width: 12),
        // Right 3 seats
        ...rightSeats.map((s) => _buildSeatTile(s)),
        // Padding if fewer than 3 right seats
        ...List.generate(3 - rightSeats.length, (_) => const SizedBox(width: 44 + 8)),
      ],
    );
  }

  Widget _buildSeatTile(SeatData seat) {
    final isMySelected = seat.status == SeatStatus.selectedByMe;
    final isAvailable  = seat.status == SeatStatus.available;
    final status = _selectedSeat == seat.number ? SeatStatus.selectedByMe : seat.status;

    Color bg, border, textColor;
    switch (status) {
      case SeatStatus.available:
        bg = Colors.white; border = const Color(0xFFF1F5F9); textColor = const Color(0xFF94A3B8);
        break;
      case SeatStatus.selectedByMe:
        bg = AppColors.seatSelected; border = AppColors.seatSelectedBorder; textColor = AppColors.primary;
        break;
      case SeatStatus.bookedMale:
        bg = AppColors.seatMale; border = AppColors.seatMaleBorder; textColor = AppColors.seatMaleText;
        break;
      case SeatStatus.bookedFemale:
        bg = AppColors.seatFemale; border = AppColors.seatFemaleBorder; textColor = AppColors.seatFemaleText;
        break;
      case SeatStatus.disabled:
        bg = AppColors.seatDisabled; border = AppColors.seatDisabledBorder; textColor = AppColors.seatDisabledText;
        break;
    }

    final tappable = status == SeatStatus.available || status == SeatStatus.selectedByMe;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: tappable
            ? () => setState(() => _selectedSeat = (_selectedSeat == seat.number) ? null : seat.number)
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 44,
          height: 36,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 2),
          ),
          child: Center(
            child: Text(
              '${seat.number}',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final hasSelection = _selectedSeat != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedSeat != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Selected: Seat $_selectedSeat', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textTitle)),
                  Text('LKR 150', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18)),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: hasSelection ? () => Navigator.of(context).pushNamed('/booking-confirm') : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasSelection ? AppColors.primary : AppColors.progressTrack,
                foregroundColor: hasSelection ? Colors.white : AppColors.textDisabled,
              ),
              child: Text(hasSelection ? 'Continue to Payment' : 'Select a Seat First'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── AppBar widget ─────────────────────────────────────────────────────────────
class _SeatAppBar extends StatelessWidget {
  final String routeName;
  const _SeatAppBar({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFF8FAFC)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Seat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25)),
                    Text('Route: $routeName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.33)),
                  ],
                ),
              ),
              Container(
                width: 40, height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Legend chip ────────────────────────────────────────────────────────────────
class _LegendChip extends StatelessWidget {
  final String label;
  final Color bg, border, textColor;
  const _LegendChip({required this.label, required this.bg, required this.border, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Text(label, style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.4)),
    );
  }
}
