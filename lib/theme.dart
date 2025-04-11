import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFF142933);    // Dark Blue
  static const Color secondaryColor = Color(0xFF23C0D8);  // Cyan
  static const Color accentColor = Color(0xFFFFD700);     // Yellow
  static const Color backgroundColor = Color(0xFF0A192F); // Dark background
  static const Color surfaceColor = Color(0xFF1A1A1A);    // Surface color
  static const Color textColor = Colors.white;            // Text color

  // Opacity levels for consistent transparency
  static const double kHighEmphasis = 1.0;
  static const double kMediumEmphasis = 0.8;
  static const double kLowEmphasis = 0.6;
  static const double kUltraLowEmphasis = 0.4;

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

  // Text Styles with Google Fonts
  static final TextTheme textTheme = TextTheme(
    // Display styles
    displayLarge: GoogleFonts.oswald(
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: -0.5,
      height: 1.2,
    ),
    displayMedium: GoogleFonts.oswald(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
      height: 1.2,
    ),
    
    // Headline styles
    headlineLarge: GoogleFonts.oswald(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textColor,
      height: 1.3,
    ),
    headlineMedium: GoogleFonts.oswald(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
      height: 1.3,
    ),
    
    // Title styles
    titleLarge: GoogleFonts.roboto(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.4,
    ),
    titleMedium: GoogleFonts.roboto(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: textColor,
      height: 1.4,
    ),
    
    // Body styles
    bodyLarge: GoogleFonts.roboto(
      fontSize: 16,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.roboto(
      fontSize: 14,
      color: textColor,
      height: 1.5,
    ),
    
    // Label styles
    labelLarge: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: textColor,
      letterSpacing: 0.5,
    ),
  );

  // Theme Data
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: textTheme,
    
    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: secondaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onBackground: Colors.white,
      onSurface: Colors.white,
      error: Colors.red.shade300,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: textColor,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondaryColor,
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: secondaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(kMediumEmphasis),
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withOpacity(kLowEmphasis),
        fontSize: 16,
      ),
      prefixIconColor: Colors.white.withOpacity(kMediumEmphasis),
      suffixIconColor: Colors.white.withOpacity(kMediumEmphasis),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: Colors.white.withOpacity(kHighEmphasis),
      size: 24,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      titleTextStyle: textTheme.titleLarge?.copyWith(color: textColor),
      contentTextStyle: textTheme.bodyLarge?.copyWith(color: textColor.withOpacity(kMediumEmphasis)),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: secondaryColor,
      disabledColor: Colors.white.withOpacity(0.05),
      labelStyle: TextStyle(
        color: Colors.white.withOpacity(kHighEmphasis),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
