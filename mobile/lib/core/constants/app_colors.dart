import 'package:flutter/material.dart';

/// RideSync brand color palette — matched to Figma design
class AppColors {
  AppColors._();

  // ── Primary brand (Figma orange) ─────────────────────────────────────────
  static const Color primary      = Color(0xFFE68D33);
  static const Color primaryDark  = Color(0xFFC97426);
  static const Color primaryLight = Color(0xFFF5A855);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent     = Color(0xFF00C9A7);
  static const Color accentDark = Color(0xFF009E82);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF60A5FA);

  // ── Seat states (matches Figma) ──────────────────────────────────────────
  /// White border only — seat is free to pick
  static const Color seatAvailable        = Colors.white;
  static const Color seatAvailableBorder  = Color(0xFFE2E8F0);
  /// Orange highlight — currently highlighted by user
  static const Color seatSelected         = Color(0x1A660409); // translucent red-900 per Figma
  static const Color seatSelectedBorder   = Color(0xFFE68D33);
  static const Color seatSelectedText     = Color(0xFFE68D33);
  /// Blue — occupied by male passenger
  static const Color seatMale             = Color(0x3360A5FA);
  static const Color seatMaleBorder       = Color(0x4C60A5FA);
  static const Color seatMaleText         = Color(0xFF60A5FA);
  /// Pink — occupied by female passenger
  static const Color seatFemale           = Color(0x33F472B6);
  static const Color seatFemaleBorder     = Color(0x4CF472B6);
  static const Color seatFemaleText       = Color(0xFFF472B6);
  /// Disabled / unavailable
  static const Color seatDisabled         = Color(0xFFF1F5F9);
  static const Color seatDisabledBorder   = Color(0xFFF1F5F9);
  static const Color seatDisabledText     = Color(0xFFCBD5E1);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF8F6F6); // Figma page bg
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceDark    = Color(0xFF1E293B);
  static const Color backgroundDark = Color(0xFF0F172A);

  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textTitle     = Color(0xFF334155);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled  = Color(0xFF94A3B8);
  static const Color textOnDark    = Color(0xFFF1F5F9);

  static const Color divider = Color(0xFFE2E8F0);
  static const Color border  = Color(0xFFE2E8F0);

  // ── GPS indicator ─────────────────────────────────────────────────────────
  static const Color gpsActive   = Color(0xFF22C55E);
  static const Color gpsInactive = Color(0xFFEF4444);
  static const Color gpsStale    = Color(0xFFF97316);

  // ── Progress bar ─────────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFF1F5F9);
}
