import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Russian Federation colors
  static const Color rougeRussie = Color(0xFFCC0000);
  static const Color bleuRussie = Color(0xFF003DA5);
  static const Color bleuDeep = Color(0xFF002480);
  static const Color blanc = Color(0xFFFFFFFF);
  static const Color or = Color(0xFFFFD700);

  // Neutrals
  static const Color bgColor = Color(0xFFF2F2F7);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFEF4444);

  // Module gradient palettes — inspired by Russian landscapes & culture
  static const List<List<Color>> moduleGradients = [
    [Color(0xFF1A0533), Color(0xFF6B21A8)],  // M1 Histoire — violet impérial
    [Color(0xFF0C3547), Color(0xFF0EA5E9)],  // M2 Géographie — bleu Sibérie
    [Color(0xFF7A0C0C), Color(0xFFCC0000)],  // M3 Politique — rouge soviétique
    [Color(0xFF1A3A5C), Color(0xFF003DA5)],  // M4 Âme russe — bleu profond
    [Color(0xFF2D4A1E), Color(0xFF4CAF50)],  // M5 Économie — vert forêt
    [Color(0xFF4A2000), Color(0xFFD97706)],  // M6 Vie quotidienne — ambre chaud
    [Color(0xFF1E0A3C), Color(0xFF7C3AED)],  // M7 Gastronomie — mauve nuit
    [Color(0xFF0A3344), Color(0xFF0284C7)],  // M8 Arts & Littérature — bleu acier
    [Color(0xFF1A3322), Color(0xFF059669)],  // M9 Musique & Cinéma — émeraude
    [Color(0xFF3D1A00), Color(0xFFB45309)],  // M10 Codes sociaux — terre brûlée
  ];

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.nunitoTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textPrimary),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: textPrimary),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: textPrimary, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: bleuRussie),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textSecondary),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: bleuRussie,
        primary: bleuRussie,
        secondary: rougeRussie,
        tertiary: or,
        surface: cardColor,
        background: bgColor,  // ignore: deprecated_member_use
        error: errorColor,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: bleuDeep,
        foregroundColor: blanc,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: blanc,
        ),
        iconTheme: const IconThemeData(color: blanc),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bleuRussie,
          foregroundColor: blanc,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: bleuRussie, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blanc,
        selectedItemColor: bleuRussie,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgColor,
        labelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
