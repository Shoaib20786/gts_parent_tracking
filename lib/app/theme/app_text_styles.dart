import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale, built on Inter via google_fonts (no local font assets to
/// manage; falls back to the platform font when offline). Always reach for one
/// of these instead of an ad-hoc TextStyle.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.inter(color: AppColors.textPrimary);

  /// Reserved for the single hero number on screen (the ETA).
  static TextStyle get display => _base.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.05,
      );

  static TextStyle get h1 =>
      _base.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.4);
  static TextStyle get h2 =>
      _base.copyWith(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3);
  static TextStyle get h3 => _base.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyMedium => _base.copyWith(fontSize: 14, height: 1.45);
  static TextStyle get bodySmall => _base.copyWith(fontSize: 13, height: 1.4);

  static TextStyle get labelLarge => _base.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => _base.copyWith(fontSize: 12, fontWeight: FontWeight.w600);

  /// Small all-caps section/overline label ("SAFETY ALERT").
  static TextStyle get overline => _base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  static TextStyle get caption =>
      _base.copyWith(fontSize: 12, height: 1.35, color: AppColors.textSecondary);

  static TextStyle get button => _base.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );
}
