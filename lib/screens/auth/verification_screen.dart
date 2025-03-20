import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../services/navigation_service.dart';
import 'login_screen.dart';
import '../../services/auth_service.dart';

class VerificationScreen extends StatelessWidget {
  final String email;
  final String userType;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: AppTheme.secondaryColor,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Verify Your Email',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'We\'ve sent a verification link to:',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Please check your email and click the verification link to complete your registration.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(
                                userType: userType,
                                title: '$userType Login',
                                subtitle: userType == 'Licensed Cleaner'
                                    ? 'Access your professional account to manage cleaning services'
                                    : 'Access your account to find and book cleaning services',
                                onLogin: (email, password) async {
                                  await AuthService.signIn(email, password);
                                },
                                onRegister: () {
                                  Navigator.pop(context);
                                },
                                additionalFields: const [],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Proceed to Login',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement resend verification email
                          NavigationService.showSuccessSnackBar(
                            'Verification email resent successfully',
                          );
                        },
                        child: Text(
                          'Resend Verification Email',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 