import 'package:flutter/material.dart';

class AppTheme {
  // 🌊 Ocean Dark
  static final dark = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF000814),
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF00D9FF),
      secondary: const Color(0xFF0077B6),
      surface: const Color(0xFF001E3C),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF001E3C).withOpacity(0.7),
      selectedItemColor: const Color(0xFF00D9FF),
      unselectedItemColor: Colors.white70,
    ),
  );

  // ☀️ Ocean Light  
  static final light = ThemeData.light().copyWith(
    scaffoldBackgroundColor: const Color(0xFFE3F2FD),
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF0077B6),
      secondary: const Color(0xFF00B4D8),
      surface: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.9),
      selectedItemColor: const Color(0xFF0077B6),
      unselectedItemColor: Colors.grey[600],
    ),
  );

  // 🔄 Theme toggle helper
  static ThemeData getTheme(bool isDark) => isDark ? dark : light;
}