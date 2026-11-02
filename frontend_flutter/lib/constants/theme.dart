import 'package:flutter/material.dart';

class LabColors {
  // Warm Paper Lab Palette
  static const Color primary = Color(0xFF8A3A03);
  static const Color primaryContainer = Color(0xFFA9511C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFE6DC);

  static const Color secondary = Color(0xFF446557);
  static const Color secondaryContainer = Color(0xFFC6EBD9);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF002116);

  static const Color surface = Color(0xFFFFF8F3);
  static const Color surfaceContainer = Color(0xFFF4EDE6);
  static const Color surfaceContainerLow = Color(0xFFFAF2EB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFEFE7E0);

  static const Color onSurface = Color(0xFF1E1B17);
  static const Color onSurfaceVariant = Color(0xFF55433A);
  static const Color outline = Color(0xFF887268);
  static const Color outlineVariant = Color(0xFFDCC1B5);

  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Dark Slate Palette
  static const Color darkSurface = Color(0xFF141210);
  static const Color darkSurfaceContainer = Color(0xFF201C18);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1714);
  static const Color darkSurfaceContainerLowest = Color(0xFF27221D);
  static const Color darkSurfaceContainerHigh = Color(0xFF2F2A24);

  static const Color darkOnSurface = Color(0xFFF5EDE6);
  static const Color darkOnSurfaceVariant = Color(0xFFD0C0B4);
  static const Color darkOutline = Color(0xFF9F8A7E);
  static const Color darkOutlineVariant = Color(0xFF5A4C44);
}

class LabTheme {
  // Impeccable Motion Curve: cubic-bezier(0.16, 1, 0.3, 1)
  static const Cubic impeccableEase = Cubic(0.16, 1.0, 0.3, 1.0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IBM Plex Sans',
      scaffoldBackgroundColor: LabColors.surface,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: LabColors.primary,
        onPrimary: LabColors.onPrimary,
        primaryContainer: LabColors.primaryContainer,
        onPrimaryContainer: LabColors.onPrimaryContainer,
        secondary: LabColors.secondary,
        onSecondary: LabColors.onSecondary,
        secondaryContainer: LabColors.secondaryContainer,
        onSecondaryContainer: LabColors.onSecondaryContainer,
        error: LabColors.error,
        onError: Colors.white,
        errorContainer: LabColors.errorContainer,
        onErrorContainer: LabColors.onErrorContainer,
        surface: LabColors.surface,
        onSurface: LabColors.onSurface,
        onSurfaceVariant: LabColors.onSurfaceVariant,
        outline: LabColors.outline,
        outlineVariant: LabColors.outlineVariant,
      ),
      cardTheme: CardTheme(
        color: LabColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: LabColors.outlineVariant, width: 0.8),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LabColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LabColors.outlineVariant, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LabColors.outlineVariant, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LabColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: LabColors.primaryContainer,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LabColors.onSurface,
          side: const BorderSide(color: LabColors.outlineVariant, width: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LabColors.surfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: LabColors.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'IBM Plex Sans',
          color: LabColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'IBM Plex Sans',
      scaffoldBackgroundColor: LabColors.darkSurface,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFFF58238),
        onPrimary: Color(0xFF341100),
        primaryContainer: LabColors.primary,
        onPrimaryContainer: LabColors.onPrimaryContainer,
        secondary: Color(0xFF74A08E),
        onSecondary: Color(0xFF002116),
        secondaryContainer: Color(0xFF213C31),
        onSecondaryContainer: Color(0xFFA5D8C3),
        error: LabColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFF680005),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: LabColors.darkSurface,
        onSurface: LabColors.darkOnSurface,
        onSurfaceVariant: LabColors.darkOnSurfaceVariant,
        outline: LabColors.darkOutline,
        outlineVariant: LabColors.darkOutlineVariant,
      ),
      cardTheme: CardTheme(
        color: LabColors.darkSurfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: LabColors.darkOutlineVariant, width: 0.8),
        ),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LabColors.darkSurfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LabColors.darkOutlineVariant, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LabColors.darkOutlineVariant, width: 0.8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFFF58238), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFF58238),
          foregroundColor: const Color(0xFF341100),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LabColors.darkOnSurface,
          side: const BorderSide(color: LabColors.darkOutlineVariant, width: 0.8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LabColors.darkSurfaceContainerLowest,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: LabColors.darkOnSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'IBM Plex Sans',
          color: LabColors.darkOnSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
        ),
      ),
    );
  }
}
