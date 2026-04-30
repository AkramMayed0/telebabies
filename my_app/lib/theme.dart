import 'package:flutter/material.dart';

class TbColors {
  static const Color yellow = Color(0xFFFFD23F);
  static const Color yellowDeep = Color(0xFFF4B400);
  static const Color pink = Color(0xFFFF4D8D);
  static const Color pinkSoft = Color(0xFFFFC2D8);
  static const Color mint = Color(0xFF2BD9A6);
  static const Color mintSoft = Color(0xFFBFF5E3);
  static const Color blue = Color(0xFF3B6BFF);
  static const Color blueSoft = Color(0xFFC8D6FF);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color coral = Color(0xFFFF6B4A);
  static const Color cream = Color(0xFFFFF7E8);
  static const Color ink = Color(0xFF1A1530);
  static const Color ink2 = Color(0xFF4A4566);
  static const Color ink3 = Color(0xFF8A85A8);
  static const Color line = Color(0xFFE8E3D5);
  static const Color bg = Color(0xFFFAF6EC);
  static const Color card = Color(0xFFFFFFFF);

  // Status colors
  static const Color statusPending = Color(0xFFFFD23F);
  static const Color statusConfirmed = Color(0xFF3B6BFF);
  static const Color statusPreparing = Color(0xFF8B5CF6);
  static const Color statusShipped = Color(0xFFFF6B4A);
  static const Color statusDelivered = Color(0xFF2BD9A6);
  static const Color statusRejected = Color(0xFFE84A5F);
}

// Font family constants
class TbFonts {
  static const String display = 'FunnelDisplay';
  static const String body = 'PlusJakartaSans';
  static const String arabic = 'IBMPlexSansArabic';
}

class TbTheme {
  static ThemeData forLocale(String lang) =>
      lang == 'ar' ? arabic : light;

  static ThemeData get light => _build('PlusJakartaSans');
  static ThemeData get arabic => _build('IBMPlexSansArabic');

  static ThemeData _build(String fontFamily) => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: TbColors.bg,
        colorScheme: const ColorScheme.light(
          primary: TbColors.pink,
          secondary: TbColors.mint,
          surface: TbColors.card,
          onPrimary: Colors.white,
          onSecondary: TbColors.ink,
          onSurface: TbColors.ink,
        ),
        fontFamily: fontFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: TbColors.bg,
          foregroundColor: TbColors.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: TbColors.card,
          selectedItemColor: TbColors.ink,
          unselectedItemColor: TbColors.ink3,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme: CardThemeData(
          color: TbColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: TbColors.line, width: 0),
          ),
          shadowColor: const Color(0x14261530),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TbColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TbColors.line, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TbColors.line, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: TbColors.pink, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: TbColors.ink,
            foregroundColor: TbColors.cream,
            shape: const StadiumBorder(),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            textStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 15),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: TbColors.pink),
        ),
        dividerTheme: const DividerThemeData(
            color: TbColors.line, thickness: 1, space: 0),
      );
}

BoxDecoration get tbCardDecoration => const BoxDecoration(
      color: TbColors.card,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      boxShadow: [
        BoxShadow(
          color: Color(0x10261530),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
    );
