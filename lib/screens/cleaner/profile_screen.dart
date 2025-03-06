import 'package:flutter/material.dart';
import '../welcome_screen.dart';
import '../../theme.dart';

class CleanerProfileScreen extends StatefulWidget {
  const CleanerProfileScreen({super.key});

  @override
  State<CleanerProfileScreen> createState() => _CleanerProfileScreenState();
}

class _CleanerProfileScreenState extends State<CleanerProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for editable fields
  final _firstNameController = TextEditingController(text: 'Sarah');
  final _lastNameController = TextEditingController(text: 'Johnson');
  final _emailController = TextEditingController(text: 'sarah.johnson@example.com');
  final _phoneController = TextEditingController(text: '(555) 987-6543');
  final _licenseController = TextEditingController(text: 'CL-2024-1234');
  final _experienceController = TextEditingController(text: '5');
  final _serviceAreasController = TextEditingController(text: 'Downtown, Midtown, Uptown');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _serviceAreasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: Icon(Icons.edit, color: AppTheme.secondaryColor),
              label: Text(
                'Edit',
                style: TextStyle(color: AppTheme.secondaryColor),
              ),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isEditing = false;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Profile updated successfully'),
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Save',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.secondaryColor,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                            if (_isEditing)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.primaryColor,
                                      width: 3,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // TODO: Implement image picker
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_isEditing) ...[
                          _buildTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your first name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your last name';
                              }
                              return null;
                            },
                          ),
                        ] else ...[
                          Text(
                            '${_firstNameController.text} ${_lastNameController.text}',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Text(
                          'Licensed Cleaner',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Sections
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection(
                        title: 'Contact Information',
                        items: [
                          if (_isEditing) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Phone',
                                    keyboardType: TextInputType.phone,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            _buildInfoItem(
                              'Email',
                              _emailController.text,
                              Icons.email_outlined,
                            ),
                            _buildInfoItem(
                              'Phone',
                              _phoneController.text,
                              Icons.phone_outlined,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSection(
                        title: 'Professional Information',
                        items: [
                          if (_isEditing) ...[
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _licenseController,
                                    label: 'License Number',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your license number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _experienceController,
                                    label: 'Years of Experience',
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your years of experience';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _serviceAreasController,
                                    label: 'Service Areas',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your service areas';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            _buildInfoItem(
                              'License Number',
                              _licenseController.text,
                              Icons.badge_outlined,
                            ),
                            _buildInfoItem(
                              'Years of Experience',
                              '${_experienceController.text} years',
                              Icons.work_outline,
                            ),
                            _buildInfoItem(
                              'Service Areas',
                              _serviceAreasController.text,
                              Icons.location_on_outlined,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildSection(
                        title: 'Account Settings',
                        items: [
                          _buildSettingItem(
                            'Security',
                            Icons.security,
                            onTap: () {
                              // TODO: Navigate to security
                            },
                          ),
                          _buildSettingItem(
                            'Notifications',
                            Icons.notifications_outlined,
                            onTap: () {
                              // TODO: Navigate to notifications
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      // Logout Button
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppTheme.primaryColor,
                                title: Text(
                                  'Logout',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to logout?',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            const begin = Offset(-1.0, 0.0);
                                            const end = Offset.zero;
                                            const curve = Curves.easeInOutCubic;
                                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                            var offsetAnimation = animation.drive(tween);
                                            return SlideTransition(
                                              position: offsetAnimation,
                                              child: child,
                                            );
                                          },
                                          transitionDuration: const Duration(milliseconds: 500),
                                        ),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      'Logout',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.logout,
                            color: Colors.red.shade400,
                          ),
                          label: Text(
                            'Logout',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white.withOpacity(0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.secondaryColor,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.red.shade300,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      validator: validator,
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.iconBoxDecoration,
            child: Icon(
              icon,
              color: AppTheme.secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        Container(
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.iconBoxDecoration,
              child: Icon(
                icon,
                color: AppTheme.secondaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
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
    );
  }
} 