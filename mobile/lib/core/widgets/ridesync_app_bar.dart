import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Standard RideSync app bar used across all screens.
/// Shows a back-arrow leading, title + optional subtitle, and an optional trailing widget.
class RideSyncAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final VoidCallback? onBack;
  final bool showBack;

  const RideSyncAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.onBack,
    this.showBack = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 72 : 60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Leading back btn
              if (showBack)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                  ),
                )
              else
                const SizedBox(width: 40),

              const SizedBox(width: 8),

              // Title + subtitle
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing actions
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
