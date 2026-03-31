import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Crimson Map spatial and decoration constants.
/// Use these everywhere instead of magic numbers.
class AppDimensions {
  AppDimensions._();

  // ── Border Radius ─────────────────────────────────────────────────────────

  static const double radiusSm = 6;
  static const double radiusMd = 10;
  static const double radiusLg = 14;
  static const double radiusXl = 20;
  static const double radiusFull = 999; // pill shape

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusPill = BorderRadius.all(Radius.circular(radiusFull));

  // ── Spacing ───────────────────────────────────────────────────────────────

  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;

  /// Standard horizontal screen padding.
  static const EdgeInsets screenPaddingH = EdgeInsets.symmetric(horizontal: space24);

  /// Standard screen padding (horizontal + vertical).
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: space24, vertical: space16);

  // ── Button Sizes ──────────────────────────────────────────────────────────

  static const double buttonHeightLg = 56;
  static const double buttonHeightMd = 44;
  static const double buttonHeightSm = 36;

  // ── Icon Sizes ────────────────────────────────────────────────────────────

  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // ── Elevation ─────────────────────────────────────────────────────────────

  static const double elevationNone = 0;
  static const double elevationSm = 1;
  static const double elevationMd = 3;
  static const double elevationLg = 6;

  // ── Common Decorations ────────────────────────────────────────────────────

  /// Standard card / container box decoration.
  static BoxDecoration cardDecoration({
    Color color = AppColors.surface,
    double radius = radiusLg,
    bool withBorder = false,
  }) =>
      BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: withBorder ? Border.all(color: AppColors.border) : null,
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      );

  /// Outlined (no fill) container decoration.
  static BoxDecoration outlinedDecoration({double radius = radiusLg}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
      );
}
