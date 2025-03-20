import 'package:flutter/material.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<void> navigateTo(Widget screen) async {
    if (context != null) {
      await Navigator.pushReplacement(
        context!,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  static void showErrorSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static void showSuccessSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  static Future<void> navigateToAndClear(Widget screen) async {
    if (context != null) {
      await Navigator.pushAndRemoveUntil(
        context!,
        MaterialPageRoute(builder: (context) => screen),
        (route) => false,
      );
    }
  }
} 