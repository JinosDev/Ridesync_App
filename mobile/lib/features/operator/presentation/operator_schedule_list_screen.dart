import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/trip_provider.dart';

class OperatorScheduleListScreen extends ConsumerWidget {
  const OperatorScheduleListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Schedules')),
      body: const Center(child: Text('Operator Schedule List — implement')),
    );
  }
}
