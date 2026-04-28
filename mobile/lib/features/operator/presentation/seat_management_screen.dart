import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SeatManagementScreen extends ConsumerWidget {
  const SeatManagementScreen({super.key, required this.scheduleId});
  final String scheduleId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Seat Management')), body: const Center(child: Text('Seat management — implement')));
  }
}
