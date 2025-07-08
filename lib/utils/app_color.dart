import 'package:flutter/material.dart';

// Definisi warna kustom
const Color primaryBaseColor = Color(
  0xFFC0C9EE,
); // Warna primer baru (biru muda/lavender)
const Color secondaryBaseColor = Color(
  0xFFFFF2E0,
); // Warna latar belakang baru (krem muda)
const Color accentColor = Color(
  0xFF8DA3DD,
); // Warna aksen yang cocok dengan primaryBaseColor
const Color textColorLight = Color(
  0xFF333333,
); // Teks gelap untuk latar belakang terang
const Color textColorDark = Color(
  0xFFF0F0F0,
); // Teks terang untuk latar belakang gelap
const Color cardColorLight = Colors.white; // Warna kartu terang
const Color cardColorDark = Color(0xFF1E1E1E); // Warna kartu gelap

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryBaseColor, // Menggunakan warna primer baru
    scaffoldBackgroundColor:
        secondaryBaseColor, // Menggunakan warna latar belakang baru
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBaseColor, // Warna app bar sesuai primary
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0, // App bar tanpa bayangan
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: primaryBaseColor,
      secondary: accentColor, // Warna aksen
      surface: cardColorLight, // Warna permukaan (misalnya untuk Card)
      onBackground: textColorLight, // Warna teks di atas background
      onSurface: textColorLight, // Warna teks di atas permukaan (Card)
    ),
    textTheme: const TextTheme(
      // Sesuaikan warna teks agar kontras dan terbaca di latar belakang terang
      displayLarge: TextStyle(color: textColorLight),
      displayMedium: TextStyle(color: textColorLight),
      displaySmall: TextStyle(color: textColorLight),
      headlineLarge: TextStyle(color: textColorLight),
      headlineMedium: TextStyle(
        color: textColorLight,
      ), // Untuk 'Selamat Datang Kembali!'
      headlineSmall: TextStyle(color: textColorLight),
      titleLarge: TextStyle(color: textColorLight),
      titleMedium: TextStyle(
        color: textColorLight,
      ), // Untuk 'Silakan masuk untuk melanjutkan'
      titleSmall: TextStyle(color: textColorLight),
      bodyLarge: TextStyle(color: textColorLight),
      bodyMedium: TextStyle(color: textColorLight),
      labelLarge: TextStyle(color: textColorLight),
      labelMedium: TextStyle(color: textColorLight),
      labelSmall: TextStyle(color: textColorLight),
    ),
    cardTheme: CardTheme(
      color: cardColorLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, // Warna teks tombol
        backgroundColor: primaryBaseColor, // Warna tombol sesuai primary
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ), // Padding lebih besar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ), // Sudut lebih bulat
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 5, // Tambahkan sedikit bayangan
        shadowColor: primaryBaseColor.withOpacity(0.5), // Warna bayangan
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor, // Warna teks untuk TextButton
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(
        0.9,
      ), // Latar belakang input field putih transparan
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), // Sudut lebih bulat
        borderSide: BorderSide.none, // Hilangkan border default
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: accentColor,
          width: 2,
        ), // Border saat fokus
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
          width: 1,
        ), // Border tipis saat tidak aktif
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ), // Padding konten input
      labelStyle: TextStyle(
        color: textColorLight.withOpacity(0.7),
      ), // Warna label
      hintStyle: TextStyle(
        color: textColorLight.withOpacity(0.5),
      ), // Warna hint
      prefixIconColor: textColorLight.withOpacity(0.6), // Warna ikon prefix
      suffixIconColor: textColorLight.withOpacity(0.6), // Warna ikon suffix
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentColor,
      linearTrackColor: Color(0xFFE0E0E0),
    ),
    iconTheme: const IconThemeData(
      color: accentColor, // Warna ikon default
    ),
  );
}
