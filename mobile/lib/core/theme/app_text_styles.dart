import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle h1 = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static const TextStyle captionBold = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white,
  );
  static const TextStyle label = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle price = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary,
  );
}
