import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF142933); // Dark Blue
  static const Color secondaryColor = Color(0xFF23C0D8); // Cyan
  static const Color accentColor = Color(0xFFFFD700); // Yellow
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color textColor = Color(0xFF43545C); // Dark Grey for text
  static const Color surfaceColor = Color(0xFFFFFFFF); // White for cards

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF142933), // Dark Blue
      Color(0xFF1D3D4A), // Slightly lighter blue
    ],
  );

  // Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
    ),
  );

  static BoxDecoration get iconBoxDecoration => BoxDecoration(
    color: secondaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  );

  // Text Styles
  static const String primaryFontFamily = 'Oswald';
  static const String bodyFontFamily = 'Roboto';

  static final TextTheme textTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: primaryColor,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    
    // Headline styles
    headlineLarge: TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: primaryColor,
    ),
    headlineMedium: TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    
    // Title styles
    titleLarge: TextStyle(
      fontFamily: primaryFontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    
    // Body styles
    bodyLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 16,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      color: textColor,
      height: 1.4,
    ),
    
    // Label styles
    labelLarge: TextStyle(
      fontFamily: bodyFontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
    ),
  );

  // Theme Data
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: textTheme,
    
    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: primaryColor,
      onBackground: textColor,
      onSurface: textColor,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(
          fontFamily: primaryFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: secondaryColor),
      ),
      labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
      hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: primaryColor,
      size: 24,
    ),
  );
}
