import 'package:flutter/material.dart';

// ── Color tokens (from brand.css) ────────────────────────────────────────────
class AppColors {
  static const Color primary   = Color(0xFFFF4D8D); // --tb-pink
  static const Color yellow    = Color(0xFFFFD23F); // --tb-yellow
  static const Color mint      = Color(0xFF2BD9A6); // --tb-mint
  static const Color blue      = Color(0xFF3B6BFF); // --tb-blue
  static const Color purple    = Color(0xFF8B5CF6); // --tb-purple
  static const Color coral     = Color(0xFFFF6B4A); // --tb-coral

  static const Color background = Color(0xFFFAF6EC); // --tb-bg
  static const Color cream      = Color(0xFFFFF7E8); // --tb-cream
  static const Color card       = Color(0xFFFFFFFF); // --tb-card

  static const Color ink  = Color(0xFF1A1530); // --tb-ink
  static const Color ink2 = Color(0xFF4A4566); // --tb-ink-2
  static const Color ink3 = Color(0xFF8A85A8); // --tb-ink-3
  static const Color line = Color(0xFFE8E3D5); // --tb-line
}

// ── Font-family tokens (from brand.css @import) ───────────────────────────────
class AppFonts {
  static const String display = 'FunnelDisplay';       // Funnel Display
  static const String body    = 'PlusJakartaSans';     // Plus Jakarta Sans
  static const String arabic  = 'IBMPlexSansArabic';  // IBM Plex Sans Arabic
}

// ── Border-radius tokens (from brand.css) ─────────────────────────────────────
class AppRadius {
  static const double sm = 10; // --tb-radius-sm
  static const double md = 18; // --tb-radius
  static const double lg = 28; // --tb-radius-lg
  static const double xl = 36; // --tb-radius-xl
}

// ── Theme builder ─────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData build({required String lang}) {
    final isAr = lang == 'ar';
    final fontFamily = isAr ? AppFonts.arabic : AppFonts.body;

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,

      // Colors
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary:     AppColors.primary,
        secondary:   AppColors.mint,
        surface:     AppColors.card,
        onPrimary:   Colors.white,
        onSecondary: AppColors.ink,
        onSurface:   AppColors.ink,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor:        AppColors.background,
        foregroundColor:        AppColors.ink,
        elevation:              0,
        scrolledUnderElevation: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color:     AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        shadowColor: const Color(0x14261530),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.line, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),

      // Primary button — pill, ink background
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.cream,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.line, thickness: 1, space: 0,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:       AppColors.card,
        selectedItemColor:     AppColors.ink,
        unselectedItemColor:   AppColors.ink3,
        showSelectedLabels:    true,
        showUnselectedLabels:  true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ── Card decoration helper ────────────────────────────────────────────────────
BoxDecoration get appCardDecoration => const BoxDecoration(
  color:        AppColors.card,
  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
  boxShadow: [
    BoxShadow(
      color:      Color(0x10261530),
      blurRadius: 24,
      offset:     Offset(0, 6),
    ),
  ],
);
