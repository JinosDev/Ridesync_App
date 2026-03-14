import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Button shape helper
  static RoundedRectangleBorder _btnShape([double r = 12]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));

  // Input border helper
  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'PublicSans', // registered in pubspec.yaml as family name
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary:   AppColors.primary,
      secondary: AppColors.accent,
      error:     AppColors.error,
      surface:   AppColors.surface,
      background: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: 'PublicSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        shape: _btnShape(),
        textStyle: const TextStyle(
          fontFamily: 'PublicSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: _btnShape(),
        textStyle: const TextStyle(
          fontFamily: 'PublicSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontFamily: 'PublicSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border:         _inputBorder(AppColors.border),
      enabledBorder:  _inputBorder(AppColors.border),
      focusedBorder:  _inputBorder(AppColors.primary, 2),
      errorBorder:    _inputBorder(AppColors.error),
      focusedErrorBorder: _inputBorder(AppColors.error, 2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontFamily: 'PublicSans',
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textDisabled,
        fontFamily: 'PublicSans',
        fontSize: 14,
      ),
    ),

    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.surface,
      margin: EdgeInsets.zero,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? AppColors.primary : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.primary.withOpacity(0.12),
      labelStyle: const TextStyle(
        fontFamily: 'PublicSans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: AppColors.border),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'PublicSans',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primaryLight,
      secondary: AppColors.accent,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
  );
}
