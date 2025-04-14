import 'package:flutter/material.dart';
import '../theme.dart';
import '../utils/responsive_utils.dart';
import 'auth/building_owner_login.dart';
import 'auth/licensed_cleaner_login.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  void _navigateWithTransition(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildUserTypeOption({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final buttonWidth = ResponsiveUtils.getCardWidth(context);
    final iconSize = ResponsiveUtils.getIconSize(context);
    final textSize = ResponsiveUtils.getBodySize(context);

    return Container(
      width: buttonWidth,
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            SizedBox(width: isSmallScreen ? 12.0 : 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: textSize * 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 4.0 : 6.0),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: textSize * 0.9,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: iconSize * 0.8,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * (ResponsiveUtils.isMobile(context) ? 0.25 : 0.15);
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context) * 0.5),
      constraints: BoxConstraints(
        maxWidth: 200,
        maxHeight: 200,
      ),
      child: CachedNetworkImage(
        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/exterior-cleaning-marketplace.firebasestorage.app/o/design%2Fassets%2Flucid-bots-logo.png?alt=media&token=bd056d16-f48d-477e-8957-3570a360f888',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
        placeholder: (context, url) => CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.cleaning_services,
          size: logoSize,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isMobile(context);
    final headingSize = ResponsiveUtils.getHeadingSize(context);
    final bodySize = ResponsiveUtils.getBodySize(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: ResponsiveUtils.getScreenPadding(context),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(child: _buildLogo(context)),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        constraints: BoxConstraints(maxWidth: 600),
                        child: Column(
                          children: [
                            Text(
                              'Welcome to the\nExterior Cleaning Marketplace',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: headingSize,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                            Text(
                              'Connect with licensed cleaning specialists',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: bodySize,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'I am a...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: headingSize * 0.7,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      _buildUserTypeOption(
                        context: context,
                        title: 'Building Owner',
                        description: 'Find licensed cleaning specialists',
                        icon: Icons.business,
                        onTap: () => _navigateWithTransition(
                          context,
                          const BuildingOwnerLoginScreen(),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12.0 : 16.0),
                      _buildUserTypeOption(
                        context: context,
                        title: 'Licensed Cleaner',
                        description: 'Join our network of operators',
                        icon: Icons.cleaning_services,
                        onTap: () => _navigateWithTransition(
                          context,
                          const LicensedCleanerLoginScreen(),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '© 2025 Lucid Bots',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: bodySize * 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 