import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'reset_password_screen.dart';

class BuildingOwnerLoginScreen extends StatelessWidget {
  const BuildingOwnerLoginScreen({super.key});

  Future<void> _handleSignIn(String email, String password) async {
    try {
      final isSignedIn = await AuthService.signIn(email, password);
      
      if (isSignedIn) {
        NavigationService.navigatorKey.currentState?.pushReplacementNamed('/building-owner/home');
      } else {
        NavigationService.showErrorSnackBar('Invalid email or password');
      }
    } catch (e) {
      NavigationService.showErrorSnackBar('Error signing in: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      userType: 'Building Owner',
      title: 'Building Owner Login',
      subtitle: 'Access your account to find and book cleaning services',
      onLogin: _handleSignIn,
      onRegister: () {
        Navigator.pushNamed(context, '/register/building-owner');
      },
      additionalFields: [
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final email = await showDialog<String>(
                context: context,
                builder: (context) => _ResetPasswordDialog(),
              );
              
              if (email != null && email.isNotEmpty) {
                try {
                  await AuthService.resetPassword(email);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResetPasswordScreen(
                        email: email,
                        userType: 'Building Owner',
                      ),
                    ),
                  );
                } catch (e) {
                  // Error is already handled in AuthService
                }
              }
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResetPasswordDialog extends StatelessWidget {
  final _emailController = TextEditingController();

  _ResetPasswordDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset Password'),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _emailController.text),
          child: const Text('Send'),
        ),
      ],
    );
  }
} 