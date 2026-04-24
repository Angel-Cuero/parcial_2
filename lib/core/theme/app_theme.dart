import 'package:flutter/material.dart';

class AppTheme {
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _secondary = Color(0xFF00D4AA);
  static const Color _background = Color(0xFF0D0D1A);
  static const Color _surface = Color(0xFF1A1A2E);
  static const Color _surfaceVariant = Color(0xFF16213E);
  static const Color _error = Color(0xFFFF6B6B);
  static const Color _onPrimary = Colors.white;
  static const Color _onBackground = Color(0xFFE8E8F0);
  static const Color _onSurface = Color(0xFFCCCCDD);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: _primary,
          secondary: _secondary,
          surface: _surface,
          error: _error,
          onPrimary: _onPrimary,
          onSecondary: Colors.black,
          onSurface: _onBackground,
          onError: Colors.white,
          surfaceContainerHighest: _surfaceVariant,
        ),
        scaffoldBackgroundColor: _background,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _onBackground,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: _onBackground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: _surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF2A2A4A), width: 1),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primary,
            side: const BorderSide(color: _primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2A2A4A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          labelStyle: const TextStyle(color: _onSurface),
          hintStyle: TextStyle(color: _onSurface.withValues(alpha: 0.5)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: _surface,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2A2A4A),
          thickness: 1,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w700, fontSize: 32),
          displayMedium: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w700, fontSize: 26),
          headlineLarge: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w600, fontSize: 22),
          headlineMedium: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w600, fontSize: 18),
          titleLarge: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge: TextStyle(color: _onBackground, fontSize: 15),
          bodyMedium: TextStyle(color: _onSurface, fontSize: 13),
          labelLarge: TextStyle(
              color: _onBackground, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _surfaceVariant,
          contentTextStyle: const TextStyle(color: _onBackground),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: _primary),
        iconTheme: const IconThemeData(color: _onSurface),
      );

  // Gradient helpers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A8CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
