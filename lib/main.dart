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
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF3CBFAE),
          secondary: const Color(0xFFFFD700),
          surface: const Color(0xFF1A1A1A),
          background: const Color(0xFF0A192F),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
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
