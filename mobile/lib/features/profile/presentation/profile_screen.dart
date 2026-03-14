import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ridesync_button.dart';
import '../../../core/widgets/error_banner.dart';
import '../../auth/providers/login_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(loginProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: user == null ? null : FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          return Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 48)),
                const SizedBox(height: AppDimensions.md),
                Text(data?['name'] as String? ?? 'User', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                if (data?['phone'] != null) ...[
                  const SizedBox(height: AppDimensions.xs),
                  Text(data!['phone'] as String, style: const TextStyle(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: AppDimensions.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(data?['role'] as String? ?? 'passenger', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
