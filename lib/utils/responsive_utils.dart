import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Responsive text sizes
  static double getHeadingSize(BuildContext context) {
    if (isMobile(context)) {
      return 24.0;
    } else if (isTablet(context)) {
      return 28.0;
    } else {
      return 32.0;
    }
  }

  static double getBodySize(BuildContext context) {
    if (isMobile(context)) {
      return 14.0;
    } else if (isTablet(context)) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  // Responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.5;
    }
  }

  // Responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Responsive button sizes
  static Size getButtonSize(BuildContext context) {
    if (isMobile(context)) {
      return const Size(120, 40);
    } else if (isTablet(context)) {
      return const Size(150, 45);
    } else {
      return const Size(180, 50);
    }
  }

  // Responsive icon sizes
  static double getIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 20.0;
    } else if (width < 1200) {
      return 24.0;
    } else {
      return 28.0;
    }
  }

  // Responsive dialog width
  static double getDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.6;
    } else {
      return screenWidth * 0.4;
    }
  }

  // Responsive list item height
  static double getListItemHeight(BuildContext context) {
    if (isMobile(context)) {
      return 72.0;
    } else if (isTablet(context)) {
      return 84.0;
    } else {
      return 96.0;
    }
  }

  // Responsive image sizes
  static double getImageSize(BuildContext context) {
    if (isMobile(context)) {
      return 120.0;
    } else if (isTablet(context)) {
      return 160.0;
    } else {
      return 200.0;
    }
  }

  static double getFontSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 14.0;
    } else if (width < 1200) {
      return 16.0;
    } else {
      return 18.0;
    }
  }

  static double getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 16.0;
    } else if (width < 1200) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  static double getButtonWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return width * 0.8;
    } else if (width < 1200) {
      return width * 0.6;
    } else {
      return width * 0.4;
    }
  }

  static double getButtonHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 48.0;
    } else if (width < 1200) {
      return 56.0;
    } else {
      return 64.0;
    }
  }
} 