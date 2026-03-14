import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../providers/trip_provider.dart';

class StatusUpdateScreen extends ConsumerStatefulWidget {
  final String scheduleId;
  const StatusUpdateScreen({super.key, required this.scheduleId});
  @override
  ConsumerState<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends ConsumerState<StatusUpdateScreen> {
  final _delayCtrl = TextEditingController();
  final _stopCtrl  = TextEditingController();

  @override
  void dispose() { _delayCtrl.dispose(); _stopCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Status')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(controller: _delayCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Delay (minutes)', prefixIcon: Icon(Icons.schedule_outlined))),
            const SizedBox(height: AppDimensions.md),
            TextFormField(controller: _stopCtrl, decoration: const InputDecoration(labelText: 'Current Stop', prefixIcon: Icon(Icons.location_on_outlined))),
            const SizedBox(height: AppDimensions.xl),
            RideSyncButton(label: 'Update', onPressed: () async {
              if (_delayCtrl.text.isNotEmpty) {
                await ref.read(tripProvider.notifier).reportDelay(widget.scheduleId, int.tryParse(_delayCtrl.text) ?? 0);
              }
              if (_stopCtrl.text.isNotEmpty) {
                await ref.read(tripProvider.notifier).updateCurrentStop(widget.scheduleId, _stopCtrl.text.trim());
              }
              if (mounted) Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }
}
