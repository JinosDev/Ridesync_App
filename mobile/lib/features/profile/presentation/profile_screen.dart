import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ridesync/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

/// Profile screen — Figma "Body" (profile) frame.
class ProfileScreenV2 extends ConsumerWidget {
  const ProfileScreenV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider).valueOrNull;
    final role = ref.watch(userRoleProvider);
    final isGuest = role == UserRole.unauthenticated;
    final name = isGuest ? 'Guest User' : (authState?.user?.displayName ?? 'User');
    final email = isGuest ? 'Sign in to access all features' : (authState?.user?.email ?? '');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              color: AppColors.primary,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 12),
                      const Text('My Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          final authState = ref.read(authStateProvider).valueOrNull;
                          if (authState == null || authState.role == UserRole.unauthenticated) {
                            context.push('/login');
                          } else {
                            // TODO: Add actual edit profile navigation
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile editing coming soon!')));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            ref.watch(authStateProvider).valueOrNull?.role == UserRole.unauthenticated ? 'Sign In' : 'Edit', 
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Avatar row (overlaps header)
            Transform.translate(
              offset: const Offset(0, -48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Avatar card
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: const Icon(Icons.person_rounded, size: 52, color: AppColors.primary),
                          ),
                          Positioned(
                            right: 0, bottom: 0,
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role == UserRole.operator ? 'Bus Operator' : 'Passenger', 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Stat(value: role == UserRole.operator ? '156' : '24', label: 'Trips'),
                          _StatDivider(),
                          if (role == UserRole.passenger) ...[
                            const _Stat(value: 'LKR 3,600', label: 'Spent'),
                            const _StatDivider(),
                          ],
                          const _Stat(value: '4.8 ⭐', label: 'Rating'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _MenuSection(title: 'Account', items: [
                      _MenuItem(icon: Icons.person_outline_rounded, label: 'Personal Information', onTap: () {}),
                      _MenuItem(icon: Icons.lock_outline_rounded, label: 'Change Password', onTap: () {}),
                      _MenuItem(icon: Icons.notifications_outlined, label: 'Notification Settings', onTap: () {}),
                    ]),
                    const SizedBox(height: 12),
                    if (role == UserRole.passenger) ...[
                      _MenuSection(title: 'Bookings', items: [
                        _MenuItem(icon: Icons.confirmation_number_outlined, label: 'Booking History', onTap: () => context.push('/booking-history')),
                        _MenuItem(icon: Icons.favorite_border_rounded, label: 'Saved Routes', onTap: () {}),
                      ]),
                    ] else if (role == UserRole.operator) ...[
                      _MenuSection(title: 'Trip Management', items: [
                        _MenuItem(icon: Icons.history_rounded, label: 'Trip History', onTap: () {}),
                        _MenuItem(icon: Icons.bus_alert_rounded, label: 'Maintenance Logs', onTap: () {}),
                      ]),
                    ],
                    const SizedBox(height: 12),
                    _MenuSection(title: 'Support', items: [
                      _MenuItem(icon: Icons.chat_bubble_outline_rounded, label: 'Chat with Assistant', onTap: () => context.push('/chatbot')),
                      _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
                      _MenuItem(icon: Icons.star_outline_rounded, label: 'Rate the App', onTap: () {}),
                    ]),
                    const SizedBox(height: 12),

                    // Logout / Sign In
                    GestureDetector(
                      onTap: () => isGuest ? context.push('/login') : _showLogoutDialog(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isGuest ? AppColors.primary.withValues(alpha: 0.08) : AppColors.error.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isGuest ? AppColors.primary.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isGuest ? Icons.login_rounded : Icons.logout_rounded, 
                              color: isGuest ? AppColors.primary : AppColors.error, 
                              size: 22
                            ),
                            const SizedBox(width: 12),
                            Text(
                              isGuest ? 'Sign In' : 'Sign Out', 
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w700, 
                                color: isGuest ? AppColors.primary : AppColors.error
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: () { 
            Navigator.pop(context); 
            context.go('/login'); 
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ],
  );
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: AppColors.border);
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});
  final String title;
  final List<_MenuItem> items;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
      ),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(
          children: items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(children: [
              e.value,
              if (!isLast) const Divider(height: 1, indent: 52, color: AppColors.border),
            ]);
          }).toList(),
        ),
      ),
    ],
  );
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    ),
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textDisabled),
    onTap: onTap,
  );
}
