import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Booking progress bar widget — "Step X of Y" header used across booking flow.
class BookingProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepLabel;

  const BookingProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = currentStep / totalSteps;
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Booking Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTitle,
                  height: 1.43,
                ),
              ),
              Text(
                'Step $currentStep of $totalSteps',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress track
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.progressTrack,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Step label row (bottom)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepLabel.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.6,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
