import 'package:flutter/material.dart';

/// Official Crimson Map color palette.
/// All colors are sourced from the Crimson Map v2 design system.
/// Do not hardcode hex values in widgets — reference these constants instead.
class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────────────────

  /// Primary crimson red. Used for AppBar, primary buttons, active states.
  static const Color primary = Color(0xFFB81013);

  /// Secondary gold. Used for accent buttons, highlights, badges.
  static const Color secondary = Color(0xFFECB034);

  // ── Text ─────────────────────────────────────────────────────────────────

  /// Default body/heading text color.
  static const Color textDark = Color(0xFF1C1C1C);

  /// White — for text rendered on colored surfaces (primary, dark bg).
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Dark text for use on the secondary (gold) surface.
  static const Color textOnSecondary = Color(0xFF1C1C1C);

  /// Secondary/subtitle text — readable mid-gray derived from the neutral.
  static const Color textSecondary = Color(0xFF6B6B6B);

  // ── Neutral / Muted ───────────────────────────────────────────────────────

  /// Muted neutral — drives borders, dividers, hints, and disabled states.
  static const Color muted = Color(0xFFC4C3C3);

  // ── Surface & Background ─────────────────────────────────────────────────

  /// App-wide scaffold background.
  static const Color background = Color(0xFFFAFAFA);

  /// Card and input field surface.
  static const Color surface = Color(0xFFFFFFFF);

  // ── Dark Theme ────────────────────────────────────────────────────────────

  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textDarkOnDark = Color(0xFFF5F5F5);

  // ── Semantic ──────────────────────────────────────────────────────────────

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF1565C0);

  // ── UI Utilities ──────────────────────────────────────────────────────────

  /// Border and divider color — matches the muted neutral.
  static const Color border = muted;
  static const Color divider = muted;

  /// Hint text color for input fields.
  static const Color hint = muted;

  /// Disabled element color.
  static const Color disabled = muted;

  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  /// Shimmer base and highlight — used by skeleton loaders.
  static const Color shimmerBase = Color(0xFFE8E8E8);
  static const Color shimmerHighlight = Color(0xFFFAFAFA);
}
