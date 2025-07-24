// lib/theme/zen_theme.dart

import 'package:flutter/material.dart';

class ZenColors {
  // Primary palette - Sage green (calming, professional)
  static const Color primarySage = Color(0xFF7C9885);
  static const Color primarySageLight = Color(0xFF9BB3A4);
  static const Color primarySageDark = Color(0xFF5A7C63);

  // Secondary palette - Warm stone
  static const Color secondaryStone = Color(0xFFB8A082);
  static const Color secondaryStoneLight = Color(0xFFD2C4A8);
  static const Color secondaryDark = Color(0xFF8B7355);

  // Neutrals - Paper-like with warm undertones
  static const Color paperWhite = Color(0xFFFAF9F7);
  static const Color paperCream = Color(0xFFF5F4F1);
  static const Color softGray = Color(0xFFE8E6E1);
  static const Color mediumGray = Color(0xFFB5B3AE);
  static const Color darkGray = Color(0xFF6B6B66);
  static const Color charcoal = Color(0xFF3A3A37);

  // Accent colors - Muted and calming
  static const Color accentBlue = Color(0xFF6B8CAE);
  static const Color accentTeal = Color(0xFF7BA3A0);
  static const Color accentAmber = Color(0xFFD4A574);

  // Status colors - Softened
  static const Color successGreen = Color(0xFF7BAE82);
  static const Color warningOrange = Color(0xFFD4A574);
  static const Color errorRed = Color(0xFFB87D7D);
  static const Color infoBlue = Color(0xFF7B9BB8);
}

class ZenTextStyles {
  static const String primaryFont = 'SF Pro Display';
  static const String monoFont = 'SF Mono';

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
    color: ZenColors.charcoal,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: ZenColors.charcoal,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: ZenColors.charcoal,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: ZenColors.darkGray,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    color: ZenColors.darkGray,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: ZenColors.mediumGray,
    height: 1.3,
  );
}

class ZenTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: ZenColors.primarySage,
        onPrimary: Colors.white,
        primaryContainer: ZenColors.primarySageLight,
        onPrimaryContainer: ZenColors.charcoal,
        secondary: ZenColors.secondaryStone,
        onSecondary: Colors.white,
        secondaryContainer: ZenColors.secondaryStoneLight,
        onSecondaryContainer: ZenColors.charcoal,
        tertiary: ZenColors.accentTeal,
        onTertiary: Colors.white,
        error: ZenColors.errorRed,
        onError: Colors.white,
        errorContainer: Color(0xFFE8D4D4),
        onErrorContainer: ZenColors.charcoal,
        surface: ZenColors.paperWhite,
        onSurface: ZenColors.charcoal,
        surfaceContainerHighest: ZenColors.softGray,
        surfaceContainer: ZenColors.paperCream,
        onSurfaceVariant: ZenColors.darkGray,
        outline: ZenColors.mediumGray,
        outlineVariant: ZenColors.softGray,
        shadow: Colors.black12,
      ),
      textTheme: const TextTheme(
        displayLarge: ZenTextStyles.displayLarge,
        headlineMedium: ZenTextStyles.headlineMedium,
        titleLarge: ZenTextStyles.titleLarge,
        bodyLarge: ZenTextStyles.bodyLarge,
        bodyMedium: ZenTextStyles.bodyMedium,
        labelMedium: ZenTextStyles.labelMedium,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ZenColors.paperWhite,
        foregroundColor: ZenColors.charcoal,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: ZenColors.charcoal,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: ZenColors.paperWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ZenColors.softGray, width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ZenColors.primarySage,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ZenColors.primarySage,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ZenColors.primarySage,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZenColors.paperCream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZenColors.softGray, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZenColors.softGray, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZenColors.primarySage, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ZenColors.errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          color: ZenColors.darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: ZenColors.mediumGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ZenColors.softGray,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ZenColors.primarySage,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ZenColors.charcoal,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ZenColors.paperWhite,
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: ZenColors.charcoal,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ZenColors.darkGray,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZenColors.paperWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

// Custom decorations for paper-like effects
// Update this part in lib/theme/theme.dart

class ZenDecorations {
  static BoxDecoration get paperCard => BoxDecoration(
    color: ZenColors.paperWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ZenColors.softGray, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x08000000),
        offset: Offset(0, 2),
        blurRadius: 8,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x04000000),
        offset: Offset(0, 1),
        blurRadius: 2,
        spreadRadius: 0,
      ),
    ],
  );

  // Option 1: Remove paper texture completely
  static BoxDecoration get paperBackground =>
      const BoxDecoration(color: ZenColors.paperWhite);

  // Option 2: Or add a subtle gradient instead
  static BoxDecoration get paperBackgroundGradient => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ZenColors.paperWhite, ZenColors.paperCream],
      stops: [0.0, 1.0],
    ),
  );

  static BoxDecoration get elevatedCard => BoxDecoration(
    color: ZenColors.paperWhite,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: ZenColors.softGray, width: 1),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        offset: Offset(0, 4),
        blurRadius: 12,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x06000000),
        offset: Offset(0, 2),
        blurRadius: 4,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration get sidePanel => BoxDecoration(
    color: ZenColors.paperCream,
    border: Border(right: BorderSide(color: ZenColors.softGray, width: 1)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x06000000),
        offset: Offset(2, 0),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  );
}
