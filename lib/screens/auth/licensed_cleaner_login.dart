import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/navigation_service.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'reset_password_screen.dart';

class LicensedCleanerLoginScreen extends StatelessWidget {
  const LicensedCleanerLoginScreen({super.key});

  Future<void> _handleSignIn(String email, String password) async {
    try {
      final isSignedIn = await AuthService.signIn(email, password);
      
      if (isSignedIn) {
        NavigationService.navigatorKey.currentState?.pushReplacementNamed('/licensed-cleaner/home');
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
      userType: 'Licensed Cleaner',
      title: 'Licensed Cleaner Login',
      subtitle: 'Access your account to manage your cleaning services',
      onLogin: _handleSignIn,
      onRegister: () {
        Navigator.pushNamed(context, '/register/licensed-cleaner');
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
                        userType: 'Licensed Cleaner',
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