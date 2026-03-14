import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../data/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyStateWidget(icon: Icons.error_outline, title: 'Failed to load notifications'),
        data: (notifs) => notifs.isEmpty
            ? const EmptyStateWidget(icon: Icons.notifications_off_outlined, title: AppStrings.noNotifications, subtitle: "You're all caught up!")
            : ListView.builder(
                itemCount: notifs.length,
                itemBuilder: (_, i) {
                  final n = notifs[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n.isRead ? AppColors.background : AppColors.primary.withOpacity(0.1),
                      child: Icon(_typeIcon(n.type), color: AppColors.primary, size: AppDimensions.iconSm),
                    ),
                    title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w600)),
                    subtitle: Text(n.body),
                    trailing: n.createdAt != null ? Text(DateFormatter.formatTime(n.createdAt!), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)) : null,
                    onTap: () => ref.read(notificationRepositoryProvider).markAsRead(n.id),
                  );
                },
              ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'booking': return Icons.confirmation_number_outlined;
      case 'delay':   return Icons.schedule_outlined;
      case 'alert':   return Icons.bus_alert_outlined;
      default:        return Icons.campaign_outlined;
    }
  }
}
