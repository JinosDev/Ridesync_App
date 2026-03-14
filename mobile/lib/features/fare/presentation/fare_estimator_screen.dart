import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../router/route_names.dart';
import '../providers/fare_provider.dart';
import '../data/fare_model.dart';
import '../../booking/providers/booking_provider.dart';

class FareEstimatorScreen extends ConsumerStatefulWidget {
  const FareEstimatorScreen({super.key});
  @override
  ConsumerState<FareEstimatorScreen> createState() => _FareEstimatorScreenState();
}

class _FareEstimatorScreenState extends ConsumerState<FareEstimatorScreen> {
  String _fromStop = '';
  String _toStop   = '';
  String _class    = 'NonAC';
  bool _fetched    = false;

  @override
  Widget build(BuildContext context) {
    final selectedScheduleId = ref.watch(bookingProvider).selectedScheduleId ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Fare Estimator')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'From Stop'), onChanged: (v) => setState(() => _fromStop = v)),
            const SizedBox(height: AppDimensions.sm),
            TextFormField(decoration: const InputDecoration(labelText: 'To Stop'),   onChanged: (v) => setState(() => _toStop   = v)),
            const SizedBox(height: AppDimensions.sm),
            DropdownButtonFormField<String>(
              value: _class,
              items: const [
                DropdownMenuItem(value: 'NonAC', child: Text('Non-AC')),
                DropdownMenuItem(value: 'AC',    child: Text('AC')),
              ],
              onChanged: (v) => setState(() => _class = v!),
              decoration: const InputDecoration(labelText: 'Bus Class'),
            ),
            const SizedBox(height: AppDimensions.md),
            RideSyncButton(label: 'Get Fare', onPressed: () {
              if (_fromStop.isEmpty || _toStop.isEmpty) return;
              setState(() => _fetched = true);
            }),

            if (_fetched && _fromStop.isNotEmpty && _toStop.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.lg),
              Consumer(
                builder: (_, ref, __) {
                  final fareAsync = ref.watch(fareProvider(FareParams(
                    scheduleId: selectedScheduleId,
                    fromStop: _fromStop, toStop: _toStop, busClass: _class,
                  )));
                  return fareAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error:   (e, _) => Text('Error: $e', style: const TextStyle(color: Colors.red)),
                    data: (fare) {
                      ref.read(bookingProvider.notifier)
                        ..selectStops(_fromStop, _toStop)
                        ..setFare(fare.total.toDouble());
                      return Column(
                        children: [
                          _FareRow('Base Fare',   CurrencyFormatter.formatInt(fare.baseFare.toInt())),
                          _FareRow('Distance',    '${fare.segmentKm} km'),
                          _FareRow('Rate/km',     CurrencyFormatter.format(fare.ratePerKm)),
                          _FareRow('Class',       '${fare.busClass} (${fare.classMultiplier}x)'),
                          const Divider(),
                          _FareRow('TOTAL', CurrencyFormatter.formatInt(fare.total), bold: true),
                          const SizedBox(height: AppDimensions.md),
                          RideSyncButton(label: 'Choose Seat', onPressed: () => context.goNamed(RouteNames.seatPicker)),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const _FareRow(this.label, this.value, {this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: bold ? const Color(0xFF1E6FFF) : null, fontSize: bold ? 18 : 14)),
      ],
    ),
  );
}
