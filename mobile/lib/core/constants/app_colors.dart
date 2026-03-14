import 'package:flutter/material.dart';

/// RideSync brand color palette
class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary        = Color(0xFF1E6FFF); // Royal Blue
  static const Color primaryDark    = Color(0xFF1252CC);
  static const Color primaryLight   = Color(0xFF5294FF);

  // Accent
  static const Color accent         = Color(0xFF00C9A7); // Teal green
  static const Color accentDark     = Color(0xFF009E82);

  // Semantic
  static const Color success        = Color(0xFF34D399);
  static const Color warning        = Color(0xFFFBBF24);
  static const Color error          = Color(0xFFEF4444);
  static const Color info           = Color(0xFF60A5FA);

  // Seat states
  static const Color seatAvailable  = Color(0xFFD1FAE5); // green-100
  static const Color seatBooked     = Color(0xFFFEE2E2); // red-100
  static const Color seatSelected   = Color(0xFFBFDBFE); // blue-200

  // Neutral
  static const Color background     = Color(0xFFF8FAFC);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceDark    = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);

  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF64748B);
  static const Color textDisabled   = Color(0xFF94A3B8);
  static const Color textOnDark     = Color(0xFFF1F5F9);

  static const Color divider        = Color(0xFFE2E8F0);
  static const Color border         = Color(0xFFCBD5E1);

  // GPS indicator
  static const Color gpsActive      = Color(0xFF22C55E);
  static const Color gpsInactive    = Color(0xFFEF4444);
  static const Color gpsStale       = Color(0xFFF97316);
}
