import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../cleaner/home_screen.dart';

class LicensedCleanerLoginScreen extends StatelessWidget {
  const LicensedCleanerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      userType: 'Licensed Cleaner',
      title: 'Licensed Cleaner Login',
      subtitle: 'Access your professional account to manage cleaning services',
      onLogin: () {
        // TODO: Add actual authentication logic
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CleanerHomeScreen(),
          ),
        );
      },
      onRegister: () {
        // TODO: Navigate to licensed cleaner registration
      },
      additionalFields: [
        TextButton(
          onPressed: () {
            // TODO: Implement forgot password
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: const Color(0xFF3CBFAE),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Not yet certified? Contact us to learn about becoming a Lucid Bots operator.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 