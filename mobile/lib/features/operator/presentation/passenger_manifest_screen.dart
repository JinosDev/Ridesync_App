import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PassengerManifestScreen extends ConsumerWidget {
  final String scheduleId;
  const PassengerManifestScreen({super.key, required this.scheduleId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(title: const Text('Passenger Manifest')), body: const Center(child: Text('Passenger list — implement')));
  }
}
