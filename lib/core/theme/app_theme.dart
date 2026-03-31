import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// Crimson Map global theme.
///
/// Usage in MaterialApp:
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// )
/// ```
class AppTheme {
  AppTheme._();

  static const String _font = 'Montserrat';

  // ── Light Theme ───────────────────────────────────────────────────────────

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: _font,

        // Color scheme — built explicitly so seed doesn't override our brand colors
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: Color(0xFFFFDAD9),
          onPrimaryContainer: Color(0xFF410002),
          secondary: AppColors.secondary,
          onSecondary: AppColors.textOnSecondary,
          secondaryContainer: Color(0xFFFFF0CC),
          onSecondaryContainer: Color(0xFF3A2800),
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
          surfaceContainerHighest: Color(0xFFF0F0F0),
          onSurfaceVariant: AppColors.textSecondary,
          outline: AppColors.border,
          outlineVariant: AppColors.muted,
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          errorContainer: Color(0xFFFFDAD6),
          onErrorContainer: Color(0xFF410002),
          shadow: AppColors.shadow,
          scrim: AppColors.overlay,
          inverseSurface: Color(0xFF313030),
          onInverseSurface: Color(0xFFF4EFEF),
          inversePrimary: Color(0xFFFFB3AE),
        ),

        scaffoldBackgroundColor: AppColors.background,

        // ── AppBar ──────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: AppDimensions.elevationNone,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textOnPrimary),
          iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
          actionsIconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        ),

        // ── Text ────────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),

        // ── Buttons ─────────────────────────────────────────────────────────

        /// Primary button — crimson background, white text.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeightLg),
            shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMd),
            elevation: AppDimensions.elevationNone,
            textStyle: AppTextStyles.buttonLarge,
          ),
        ),

        /// Secondary/accent button — gold background, dark text.
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnSecondary,
            minimumSize: const Size(double.infinity, AppDimensions.buttonHeightMd),
            shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMd),
            side: BorderSide.none,
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),

        /// Text/ghost button — no background.
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.buttonMedium,
            shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMd),
          ),
        ),

        // ── Input Fields ────────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.hint),
          labelStyle: AppTextStyles.label,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space12,
          ),
          border: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppDimensions.borderRadiusMd,
            borderSide: const BorderSide(color: AppColors.disabled),
          ),
        ),

        // ── Cards ────────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: AppDimensions.elevationSm,
          shadowColor: AppColors.shadow,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLg),
          margin: EdgeInsets.zero,
        ),

        // ── Bottom Nav ───────────────────────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppTextStyles.captionXS,
          unselectedLabelStyle: AppTextStyles.captionXS,
        ),

        // ── Divider ──────────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── Chip ─────────────────────────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.background,
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.buttonMedium,
          side: const BorderSide(color: AppColors.border),
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusPill),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: AppDimensions.space4,
          ),
        ),

        // ── ListTile ─────────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space4,
          ),
          titleTextStyle: AppTextStyles.titleMedium,
          subtitleTextStyle: AppTextStyles.bodySmall,
          iconColor: AppColors.textSecondary,
        ),

        // ── Switch / Checkbox / Radio ─────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? AppColors.primary : AppColors.muted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.muted.withValues(alpha: 0.3),
          ),
        ),

        // ── SnackBar ─────────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textDark,
          contentTextStyle: AppTextStyles.body.copyWith(color: AppColors.textOnPrimary),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMd),
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        fontFamily: _font,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          primaryContainer: const Color(0xFF7F0002),
          onPrimaryContainer: const Color(0xFFFFDAD9),
          secondary: AppColors.secondary,
          onSecondary: AppColors.textOnSecondary,
          secondaryContainer: const Color(0xFF5A3E00),
          onSecondaryContainer: const Color(0xFFFFF0CC),
          surface: AppColors.surfaceDark,
          onSurface: AppColors.textDarkOnDark,
          surfaceContainerHighest: const Color(0xFF2C2C2C),
          onSurfaceVariant: AppColors.muted,
          outline: AppColors.muted,
          outlineVariant: AppColors.muted.withValues(alpha: 0.5),
          error: AppColors.error,
          onError: AppColors.textOnPrimary,
          errorContainer: const Color(0xFF7F0002),
          onErrorContainer: const Color(0xFFFFDAD9),
          shadow: AppColors.shadow,
          scrim: AppColors.overlay,
          inverseSurface: AppColors.background,
          onInverseSurface: AppColors.textDark,
          inversePrimary: const Color(0xFFB81013),
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textDarkOnDark,
          elevation: AppDimensions.elevationNone,
          centerTitle: true,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textDarkOnDark),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge.copyWith(color: AppColors.textDarkOnDark),
          headlineLarge: AppTextStyles.headlineLarge.copyWith(color: AppColors.textDarkOnDark),
          headlineSmall: AppTextStyles.headlineSmall.copyWith(color: AppColors.textDarkOnDark),
          titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textDarkOnDark),
          titleMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textDarkOnDark),
          bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textDarkOnDark),
          bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDarkOnDark),
          bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.muted),
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium.copyWith(color: AppColors.muted),
          labelSmall: AppTextStyles.labelSmall,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surfaceDark,
          elevation: AppDimensions.elevationNone,
          shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLg),
          margin: EdgeInsets.zero,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.muted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: DividerThemeData(
          color: AppColors.muted.withValues(alpha: 0.3),
          thickness: 1,
          space: 1,
        ),
      );
}
