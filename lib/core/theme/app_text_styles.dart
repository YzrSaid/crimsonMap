import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Crimson Map typography system.
///
/// Font family: Montserrat
/// Place font files under assets/fonts/Montserrat/ and declare them in pubspec.yaml.
///
/// Scale (from design system):
/// ┌──────────────────┬────────┬───────────┐
/// │ Role             │  Size  │  Weight   │
/// ├──────────────────┼────────┼───────────┤
/// │ Display          │  32    │  Bold     │
/// │ H2               │  24    │  SemiBold │
/// │ H3               │  18    │  SemiBold │
/// │ Body             │  14    │  Regular  │
/// │ Label            │  14    │  Regular  │
/// │ Button Large     │  18    │  SemiBold │
/// │ Button Medium    │  14    │  SemiBold │
/// │ Caption          │  12    │  Light    │
/// └──────────────────┴────────┴───────────┘
class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Montserrat';

  // ── Display ───────────────────────────────────────────────────────────────

  static const TextStyle display = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // ── Headlines ─────────────────────────────────────────────────────────────

  /// H2 — 24px SemiBold. Section titles, card headers.
  static const TextStyle h2 = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.3,
  );

  /// H3 — 18px SemiBold. Sub-section titles, list headers.
  static const TextStyle h3 = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );

  // ── Body ──────────────────────────────────────────────────────────────────

  /// Standard body text — 14px Regular.
  static const TextStyle body = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
  );

  /// Slightly larger body — 16px Regular. Used for readable paragraphs.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.6,
  );

  // ── Label ─────────────────────────────────────────────────────────────────

  /// Label — 14px Regular. Form labels, metadata, tags.
  static const TextStyle label = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
  );

  // ── Buttons ───────────────────────────────────────────────────────────────

  /// Button Large — 18px SemiBold. Primary / hero CTAs.
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1,
  );

  /// Button Medium — 14px SemiBold. Secondary buttons, inline actions.
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1,
  );

  // ── Caption ───────────────────────────────────────────────────────────────

  /// Caption — 12px Light. Timestamps, footnotes, fine print.
  static const TextStyle caption = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.muted,
    height: 1.4,
  );

  /// Extra-small caption — 10px Light.
  static const TextStyle captionXS = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w300,
    color: AppColors.muted,
    height: 1.4,
  );

  // ── Flutter TextTheme mappings ────────────────────────────────────────────
  // Named to match Flutter's TextTheme slots so AppTheme can reference them
  // directly without extra lookup.

  static const TextStyle displayLarge = display;
  static const TextStyle headlineLarge = h2;
  static const TextStyle headlineSmall = h3;
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
    height: 1.4,
  );
  static const TextStyle titleMedium = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
    height: 1.5,
  );
  static const TextStyle bodyMedium = body;
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  static const TextStyle labelLarge = buttonMedium;
  static const TextStyle labelMedium = label;
  static const TextStyle labelSmall = captionXS;
}
