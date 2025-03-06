import 'package:flutter/material.dart';
import 'auth/building_owner_login.dart';
import 'auth/licensed_cleaner_login.dart';
import '../theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _navigateWithTransition(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Main Content
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // App Bar
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        color: AppTheme.secondaryColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.hexagon_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'LUCID BOTS',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Hero Text
                              Text(
                                'Welcome to the\nExterior Cleaning Marketplace',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connect with licensed cleaning specialists using advanced Lucid Bots technology',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 60),
                              
                              // User Type Selection
                              Container(
                                constraints: const BoxConstraints(maxWidth: 600),
                                child: Column(
                                  children: [
                                    Text(
                                      'I am a...',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildUserTypeOption(
                                      context: context,
                                      title: 'Building Owner',
                                      description: 'Find licensed cleaning specialists in your area',
                                      icon: Icons.business,
                                      onTap: () {
                                        _navigateWithTransition(
                                          context,
                                          const BuildingOwnerLoginScreen(),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildUserTypeOption(
                                      context: context,
                                      title: 'Licensed Cleaner',
                                      description: 'Join our network of Lucid Bots operators',
                                      icon: Icons.cleaning_services,
                                      onTap: () {
                                        _navigateWithTransition(
                                          context,
                                          const LicensedCleanerLoginScreen(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Trademark Text at bottom
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '© 2024 Lucid Bots. All rights reserved.',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.iconBoxDecoration,
                child: Icon(
                  icon,
                  color: AppTheme.secondaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 