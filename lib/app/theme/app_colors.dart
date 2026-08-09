import 'package:flutter/material.dart';

/// Single source of truth for every color in the app.
/// Never hardcode a `Color(0x...)` in a screen or widget — add a token here first.
///
/// Palette intent: a calm, trustworthy parent-facing safety product.
/// Light neutral surfaces, strong dark typography, one restrained teal accent,
/// and soft tinted containers reserved for safety states.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0F766E); // deep teal — accent, route, actions
  static const Color primaryPressed = Color(0xFF115E59);
  static const Color primarySoft = Color(0xFFE6F4F2); // tinted chip/pill background
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A); // slate-900
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // slate-400

  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const Color scaffoldBackground = Color(0xFFF4F6F8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE6EAF0);
  static const Color cardShadow = Color(0x140F172A);

  // ── Safety states ─────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerPressed = Color(0xFFB91C1C);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFFECACA);

  static const Color warning = Color(0xFFB45309);
  static const Color warningSoft = Color(0xFFFFF7E6);
  static const Color warningBorder = Color(0xFFFDE6B3);

  static const Color success = Color(0xFF16803C);
  static const Color successSoft = Color(0xFFF0FDF4);
  static const Color successBorder = Color(0xFFBBF7D0);

  static const Color ratingStar = Color(0xFFF59E0B);

  // ── Map ───────────────────────────────────────────────────────────────────
  static const Color mapBackground = Color(0xFFE8ECEF); // behind tiles while loading
  static const Color routeTravelled = primary;
  static const Color routeRemaining = Color(0xFF8DA2B4);
  static const Color liveDot = Color(0xFFEF4444);

  // ── Shared ────────────────────────────────────────────────────────────────
  static const Color overlay = Color(0x8010172A);
}
