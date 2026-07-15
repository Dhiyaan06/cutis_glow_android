import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna diambil langsung dari kelas Tailwind yang dipakai di web
/// Laravel-nya (resources/views/**/*.blade.php) supaya tampilan Flutter
/// dan web punya identitas visual yang sama -- "cutis glow pink".
class AppColors {
  AppColors._();

  // Pink (warna utama brand -- dari kelas `pink-*` di web)
  static const pink50 = Color(0xFFFDF2F8);
  static const pink100 = Color(0xFFFCE7F3);
  static const pink200 = Color(0xFFFBCFE8);
  static const pink400 = Color(0xFFF472B6);
  static const pink500 = Color(0xFFEC4899);
  static const pink600 = Color(0xFFDB2777); // warna utama (primary)
  static const pink700 = Color(0xFFBE185D);
  static const pink900 = Color(0xFF831843);

  // Netral (dari kelas `gray-*` / `slate-*` di web, dipakai buat teks & border)
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray800 = Color(0xFF1F2937);

  // Status badge (dari kelas warna di dashboard admin: yellow/emerald/red/blue)
  static const statusPendingBg = Color(0xFFFEF9C3);
  static const statusPendingText = Color(0xFF854D0E);
  static const statusSuccessBg = Color(0xFFD1FAE5);
  static const statusSuccessText = Color(0xFF065F46);
  static const statusDangerBg = Color(0xFFFEE2E2);
  static const statusDangerText = Color(0xFF991B1B);
  static const statusInfoBg = Color(0xFFDBEAFE);
  static const statusInfoText = Color(0xFF1E40AF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.pink600,
      onPrimary: Colors.white,
      primaryContainer: AppColors.pink100,
      onPrimaryContainer: AppColors.pink900,
      secondary: AppColors.pink400,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.gray800,
      error: Color(0xFFDC2626),
      onError: Colors.white,
    );

    final baseTextTheme = GoogleFonts.figtreeTextTheme();
    final textTheme = baseTextTheme.apply(
      bodyColor: AppColors.gray800,
      displayColor: AppColors.gray800,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.pink50,
      textTheme: textTheme,
      fontFamily: GoogleFonts.figtree().fontFamily,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.pink700,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: AppColors.pink700,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.pink100, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.pink100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.pink100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.pink600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        labelStyle: const TextStyle(color: AppColors.gray600),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pink600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.pink600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.pink600),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pink600,
          side: const BorderSide(color: AppColors.pink600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.pink600,
        foregroundColor: Colors.white,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.pink50,
        labelStyle: const TextStyle(color: AppColors.pink700),
        side: BorderSide(color: AppColors.pink100),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray800,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.pink100),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.pink600,
      ),
    );
  }
}
