import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth/building_owner_login.dart';
import 'screens/auth/licensed_cleaner_login.dart';
import 'screens/auth/building_owner_register.dart';
import 'screens/auth/licensed_cleaner_register.dart';
import 'screens/building_owner/home_screen.dart';
import 'screens/cleaner/home_screen.dart';
import 'services/navigation_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  
  // Initialize Google Fonts
  GoogleFonts.config.allowRuntimeFetching = true;
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      title: 'Lucid Bots Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const WelcomeScreen(),
      routes: {
        '/login/building-owner': (context) => const BuildingOwnerLoginScreen(),
        '/login/licensed-cleaner': (context) => const LicensedCleanerLoginScreen(),
        '/register/building-owner': (context) => const BuildingOwnerRegisterScreen(),
        '/register/cleaner': (context) => const LicensedCleanerRegisterScreen(),
        '/building-owner/home': (context) => const BuildingOwnerHomeScreen(),
        '/cleaner/home': (context) => const CleanerHomeScreen(),
      },
    );
  }
}
