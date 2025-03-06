import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../building_owner/home_screen.dart';

class BuildingOwnerLoginScreen extends StatelessWidget {
  const BuildingOwnerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      userType: 'Building Owner',
      title: 'Building Owner Login',
      subtitle: 'Access your account to find and book cleaning services',
      onLogin: () {
        // TODO: Add actual authentication logic
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BuildingOwnerHomeScreen(),
          ),
        );
      },
      onRegister: () {
        // TODO: Navigate to building owner registration
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
      ],
    );
  }
} 