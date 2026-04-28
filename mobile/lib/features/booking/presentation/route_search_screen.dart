import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteSearchScreen extends ConsumerWidget {
  const RouteSearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Routes')),
      body: const Center(child: Text('Route Search — coming soon')),
    );
  }
}
