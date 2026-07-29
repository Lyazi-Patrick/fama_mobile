import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors and type scale copied directly from
/// stitch_fama_agricultural_platform_ui_kit/fama_agricultural_design_system/DESIGN.md
/// so every screen — generated or hand-built — looks like one app.
class FamaColors {
  static const primary = Color(0xFF0D631B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF2E7D32);
  static const onPrimaryContainer = Color(0xFFCBFFC2);

  static const secondary = Color(0xFF964900); // "Harvest Gold" family
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFE851F);
  static const onSecondaryContainer = Color(0xFF612D00);

  static const tertiary = Color(0xFF6D4E45); // "Earth Brown"
  static const onTertiary = Color(0xFFFFFFFF);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);

  static const background = Color(0xFFFBF9F5); // "Warm Parchment"
  static const onBackground = Color(0xFF1B1C1A);
  static const surfaceContainerLow = Color(0xFFF5F3EF);
  static const surfaceContainer = Color(0xFFEFEEEA);
  static const outline = Color(0xFF707A6C);
  static const outlineVariant = Color(0xFFBFCABA);
}

class FamaTheme {
  static ThemeData get light {
    // "Atkinson Hyperlegible" is the closest Google Fonts match to the
    // design system's "Atkinson Hyperlegible Next" (built for readability
    // at a glance -- useful for users on budget/low-res screens).
    final headingFont = GoogleFonts.plusJakartaSans;
    final bodyFont = GoogleFonts.atkinsonHyperlegible;

    final colorScheme = const ColorScheme.light(
      primary: FamaColors.primary,
      onPrimary: FamaColors.onPrimary,
      primaryContainer: FamaColors.primaryContainer,
      onPrimaryContainer: FamaColors.onPrimaryContainer,
      secondary: FamaColors.secondary,
      onSecondary: FamaColors.onSecondary,
      secondaryContainer: FamaColors.secondaryContainer,
      onSecondaryContainer: FamaColors.onSecondaryContainer,
      tertiary: FamaColors.tertiary,
      onTertiary: FamaColors.onTertiary,
      error: FamaColors.error,
      onError: FamaColors.onError,
      surface: FamaColors.background,
      onSurface: FamaColors.onBackground,
      outline: FamaColors.outline,
      outlineVariant: FamaColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FamaColors.background,
      textTheme: TextTheme(
        headlineLarge: headingFont(fontSize: 28, fontWeight: FontWeight.w700, height: 36 / 28),
        headlineMedium: headingFont(fontSize: 20, fontWeight: FontWeight.w600, height: 28 / 20),
        bodyLarge: bodyFont(fontSize: 18, fontWeight: FontWeight.w400, height: 26 / 18),
        bodyMedium: bodyFont(fontSize: 16, fontWeight: FontWeight.w400, height: 24 / 16),
        labelLarge: bodyFont(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
        labelSmall: bodyFont(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      // Pill-shaped primary buttons, 56px tall -- matches DESIGN.md's
      // "Primary: Solid Fertile Green ... height of 56px for main mobile actions."
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FamaColors.primary,
          foregroundColor: FamaColors.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FamaColors.primary,
          minimumSize: const Size.fromHeight(56),
          shape: const StadiumBorder(),
          side: const BorderSide(color: FamaColors.primary, width: 2),
          textStyle: bodyFont(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      // "Outlined" style with persistent labels, 8px rounding per DESIGN.md.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FamaColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FamaColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FamaColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FamaColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: FamaColors.background,
        indicatorColor: FamaColors.primaryContainer,
      ),
    );
  }
}
