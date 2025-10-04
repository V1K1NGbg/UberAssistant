import 'package:flutter/material.dart';
import 'constants.dart';

ThemeData buildLightTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: K.safetyBlue,
      brightness: Brightness.light,
      primary: K.uberBlack,
      secondary: K.safetyBlue,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: K.uberBlack,
      elevation: 0,
    ),
    // ThemeData.cardTheme now expects CardThemeData
    cardTheme: const CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: K.cardRadius),
      elevation: 0.5,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF5F5F7),
      border: OutlineInputBorder(
        borderRadius: K.cardRadius,
        borderSide: BorderSide(color: Colors.transparent),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: K.safetyBlue,
      brightness: Brightness.dark,
      primary: Colors.white,
      secondary: K.safetyBlue,
    ),
  );

  return base.copyWith(
    scaffoldBackgroundColor: K.uberEbony,
    appBarTheme: const AppBarTheme(
      backgroundColor: K.uberEbony,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF121212),
      shape: RoundedRectangleBorder(borderRadius: K.cardRadius),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: K.cardRadius,
        borderSide: BorderSide(color: Colors.transparent),
      ),
    ),
  );
}
