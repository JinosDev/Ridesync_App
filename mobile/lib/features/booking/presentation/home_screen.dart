import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/widgets/ridesync_text_field.dart';
import '../../../router/route_names.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _fromCtrl = TextEditingController();
  final _toCtrl   = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _search() {
    if (_fromCtrl.text.trim().isEmpty || _toCtrl.text.trim().isEmpty) return;
    context.goNamed(
      RouteNames.schedules,
      queryParameters: {
        'from': _fromCtrl.text.trim(),
        'to':   _toCtrl.text.trim(),
        'date': DateFormatter.toApiDate(_selectedDate),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.goNamed(RouteNames.notifications)),
          IconButton(icon: const Icon(Icons.person_outline),         onPressed: () => context.goNamed(RouteNames.profile)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Find Your Bus', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppDimensions.md),
            RideSyncTextField(controller: _fromCtrl, label: AppStrings.from, prefixIcon: const Icon(Icons.trip_origin),   validator: Validators.requiredField),
            const SizedBox(height: AppDimensions.sm),
            RideSyncTextField(controller: _toCtrl,   label: AppStrings.to,   prefixIcon: const Icon(Icons.location_on_outlined), validator: Validators.requiredField),
            const SizedBox(height: AppDimensions.sm),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormatter.formatDate(_selectedDate)),
            ),
            const SizedBox(height: AppDimensions.md),
            RideSyncButton(label: AppStrings.searchBuses, icon: Icons.search, onPressed: _search),
            const SizedBox(height: AppDimensions.xl),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppDimensions.sm),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.sm,
              mainAxisSpacing: AppDimensions.sm,
              childAspectRatio: 1.8,
              children: [
                _QuickAction(icon: Icons.book_online_outlined,   label: 'My Bookings',    onTap: () => context.goNamed(RouteNames.myBookings)),
                _QuickAction(icon: Icons.calculate_outlined,     label: 'Fare Estimator', onTap: () => context.goNamed(RouteNames.fareEstimator)),
                _QuickAction(icon: Icons.chat_bubble_outline,    label: 'Assistant',      onTap: () => context.goNamed(RouteNames.chatbot)),
                _QuickAction(icon: Icons.location_on_outlined,   label: 'Track Bus',      onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.sm),
          child: Row(children: [
            Icon(icon, color: const Color(0xFF1E6FFF)),
            const SizedBox(width: AppDimensions.sm),
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          ]),
        ),
      ),
    );
  }
}
