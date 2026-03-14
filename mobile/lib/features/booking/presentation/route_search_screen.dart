import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../router/route_names.dart';
import '../providers/booking_provider.dart';

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
