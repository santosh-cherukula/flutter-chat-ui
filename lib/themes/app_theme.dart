import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final class AppTheme {
  static const seed = Color(0xFF7F5AF0);

  static ThemeData light = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xFFF5F7FA),
    onSurface: Colors.black,
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),

  // 🟣 Glass card that pops in light mode
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: Color(0xFFD3D3D3), width: 0.5), // subtle outline
    ),
    elevation: 0,
    color: Colors.white.withOpacity(.95), // more opaque glass
  ),

  listTileTheme: const ListTileThemeData(iconColor: Colors.black87),
);

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      surface: const Color(0xFF0D0D0D),
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B0B0C),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      color: Colors.white.withOpacity(.08),
    ),
    listTileTheme: const ListTileThemeData(iconColor: Colors.white70),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? seed : Colors.white24),
      thumbColor: WidgetStateProperty.all(Colors.white),
    ),
  );
}