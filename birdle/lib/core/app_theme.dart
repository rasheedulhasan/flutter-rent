import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized app theme with the ProManager property management color palette.
class AppTheme {
  // ===========================================================================
  // ProManager Color Palette (from HTML design)
  // ===========================================================================
  static const Color primary = Color(0xFF0058BC);
  static const Color primaryContainer = Color(0xFF0070EB);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF004493);
  static const Color primaryFixed = Color(0xFFD8E2FF);
  static const Color primaryFixedDim = Color(0xFFADC6FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixed = Color(0xFF001A41);
  static const Color onPrimaryFixedVariant = Color(0xFF004493);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);

  static const Color secondary = Color(0xFF575E70);
  static const Color secondaryFixed = Color(0xFFDCE2F7);
  static const Color secondaryFixedDim = Color(0xFFC0C6DB);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryFixed = Color(0xFF141B2B);
  static const Color onSecondaryFixedVariant = Color(0xFF404758);
  static const Color secondaryContainer = Color(0xFFD9DFF5);
  static const Color onSecondaryContainer = Color(0xFF5C6274);

  static const Color tertiary = Color(0xFF9E3D00);
  static const Color tertiaryContainer = Color(0xFFC64F00);
  static const Color tertiaryFixed = Color(0xFFFFDBCC);
  static const Color tertiaryFixedDim = Color(0xFFFFB595);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryFixed = Color(0xFF351000);
  static const Color onTertiaryFixedVariant = Color(0xFF7C2E00);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceDim = Color(0xFFD8D9E5);
  static const Color surfaceBright = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F3FE);
  static const Color surfaceContainer = Color(0xFFECEDF9);
  static const Color surfaceContainerHigh = Color(0xFFE6E8F3);
  static const Color surfaceContainerHighest = Color(0xFFE0E2ED);
  static const Color surfaceVariant = Color(0xFFE0E2ED);
  static const Color onSurface = Color(0xFF181C23);
  static const Color onSurfaceVariant = Color(0xFF414755);
  static const Color outline = Color(0xFF717786);
  static const Color outlineVariant = Color(0xFFC1C6D7);
  static const Color inverseSurface = Color(0xFF2D3039);
  static const Color inverseOnSurface = Color(0xFFEEF0FC);
  static const Color inversePrimary = Color(0xFFADC6FF);
  static const Color surfaceTint = Color(0xFF005BC1);

  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF181C23);

  // Legacy aliases for backward compatibility
  static const Color accent = Color(0xFF00D9A6);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // Card colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF1A1A2E);
  static const Color textPrimaryLight = Color(0xFF181C23);
  static const Color textSecondaryLight = Color(0xFF414755);
  static const Color textPrimaryDark = Color(0xFFF1F1F6);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF2D2D44);

  // Backward compatibility aliases
  static const Color surfaceLight = surface;
  static const Color surfaceDark = Color(0xFF0F0F1A);

  // Shimmer
  static const Color shimmerBaseLight = Color(0xFFE5E7EB);
  static const Color shimmerHighlightLight = Color(0xFFF3F4F6);
  static const Color shimmerBaseDark = Color(0xFF2D2D44);
  static const Color shimmerHighlightDark = Color(0xFF3D3D54);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00B894)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const List<Color> chartColors = [
    Color(0xFF0058BC),
    Color(0xFF00D9A6),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
  ];

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: error,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      onError: onError,
      outline: outline,
      outlineVariant: outlineVariant,
      inversePrimary: inversePrimary,
      inverseSurface: inverseSurface,
    ),
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.02),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: -0.01),
      displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      headlineLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      headlineMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: onSurface),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
      titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface, height: 1.5),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface, height: 1.43),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant, height: 1.33),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: onSurface),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceVariant),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: outlineVariant, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: primary),
      shape: const Border(bottom: BorderSide(color: outlineVariant, width: 0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primary,
      unselectedItemColor: onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: onSurfaceVariant, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceContainerLow,
      selectedColor: primary.withValues(alpha: 0.15),
      labelStyle: GoogleFonts.inter(fontSize: 12, color: onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: outlineVariant),
    ),
    dividerTheme: const DividerThemeData(color: outlineVariant, thickness: 0.5, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryFixedDim,
      surface: Color(0xFF0F0F1A),
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFF1F1F6),
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w700, color: textPrimaryDark, letterSpacing: -0.02),
      displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimaryDark, letterSpacing: -0.01),
      displaySmall: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryDark),
      headlineLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryDark),
      headlineMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryDark),
      headlineSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimaryDark),
      titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textPrimaryDark),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryDark),
      titleSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimaryDark),
      bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimaryDark),
      bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimaryDark),
      bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondaryDark),
      labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryDark),
      labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimaryDark),
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondaryDark),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: borderDark, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: primaryLight),
      shape: const Border(bottom: BorderSide(color: borderDark, width: 0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F0F1A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: GoogleFonts.inter(color: textSecondaryDark, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        side: const BorderSide(color: primaryLight),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF0F0F1A),
      selectedColor: primary.withValues(alpha: 0.25),
      labelStyle: GoogleFonts.inter(fontSize: 12, color: textPrimaryDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: borderDark),
    ),
    dividerTheme: const DividerThemeData(color: borderDark, thickness: 0.5, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
