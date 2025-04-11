import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'auth/building_owner_login.dart';
import 'auth/licensed_cleaner_login.dart';
import '../theme.dart';
import '../services/storage_service.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildLogo(BuildContext context) {
    final storageService = StorageService();
    return FutureBuilder<String>(
      future: storageService.getDesignAssetUrl('lucid-bots-logo.png'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading logo URL...');
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print('Error loading logo URL: ${snapshot.error}');
          print('Error type: ${snapshot.error.runtimeType}');
          if (snapshot.error is FirebaseException) {
            final error = snapshot.error as FirebaseException;
            print('Firebase error code: ${error.code}');
            print('Firebase error message: ${error.message}');
            print('Firebase error stack: ${error.stackTrace}');
            print('Firebase error plugin: ${error.plugin}');
          }
          // Try to get more details about the error
          print('Full error stack trace: ${snapshot.stackTrace}');
          
          return const SizedBox(
            height: 60,
            child: Center(
              child: Text(
                'LUCID BOTS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final imageUrl = snapshot.data!;
          print('Attempting to load image from URL: $imageUrl');
          return SizedBox(
            height: 60,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  print('Image loaded successfully');
                  return child;
                }
                final progress = loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null;
                print('Loading progress: ${(progress ?? 0) * 100}%');
                return Center(
                  child: CircularProgressIndicator(
                    value: progress,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Image.network error: $error');
                print('Image.network error type: ${error.runtimeType}');
                print('Image.network stack trace: $stackTrace');
                return const Center(
                  child: Text(
                    'LUCID BOTS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          );
        }

        print('No URL data received');
        return const SizedBox(
          height: 60,
          child: Center(
            child: Text(
              'LUCID BOTS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

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
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 40, bottom: 40),
                                child: Center(child: _buildLogo(context)),
                              ),
                              Text(
                                'Welcome to the\nExterior Cleaning Marketplace',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Connect with licensed cleaning specialists using advanced Lucid Bots technology',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 60),
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        '© 2025 Lucid Bots. All rights reserved.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
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