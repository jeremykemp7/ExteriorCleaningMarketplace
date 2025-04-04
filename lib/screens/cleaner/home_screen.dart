import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'profile_screen.dart';
import '../../theme.dart';
import '../../services/navigation_service.dart';
import '../welcome_screen.dart';

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({super.key});

  static void navigate() {
    NavigationService.navigateTo(const CleanerHomeScreen());
  }

  @override
  State<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  bool _isAvailable = true;

  void _handleSignOut() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      (route) => false,
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
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
        actions: [
          // Navigation Items
          IconButton(
            iconSize: 28,
            icon: const Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Navigate to schedule
            },
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(
              Icons.message_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Navigate to messages
            },
          ),
          // Availability Toggle in AppBar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(
                  _isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                    color: _isAvailable ? Theme.of(context).colorScheme.secondary : Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            iconSize: 28,
            icon: const Icon(
              Icons.person_outline,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CleanerProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 0),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    children: [
                      // Header Section
                      Padding(
                        padding: const EdgeInsets.only(top: 48, bottom: 24),
                        child: Column(
                          children: [
                            Text(
                              'Welcome Back, ${_getTimeBasedGreeting()}',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Find and manage your cleaning jobs',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Search and Filter Section
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search available jobs...',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.filter_list),
                                    onPressed: () {
                                      // TODO: Implement filter
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Service Categories
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildCategoryChip('All Jobs', true),
                          _buildCategoryChip('Window Cleaning', false),
                          _buildCategoryChip('Facade Cleaning', false),
                          _buildCategoryChip('Pressure Washing', false),
                          _buildCategoryChip('Solar Panel Cleaning', false),
                          _buildCategoryChip('Gutter Cleaning', false),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                int crossAxisCount;
                if (constraints.crossAxisExtent > 800) {
                  crossAxisCount = 4;
                } else if (constraints.crossAxisExtent > 600) {
                  crossAxisCount = 3;
                } else {
                  crossAxisCount = 2;
                }
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildJobCard(
                      buildingName: 'Office Tower ${index + 1}',
                      jobType: 'Window Cleaning',
                      price: '\$350',
                      imageUrl: 'https://picsum.photos/400/300',
                      distance: '3.2 miles away',
                      scheduledTime: 'Today, 2:00 PM',
                      status: 'Scheduled',
                    ),
                    childCount: 8,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (bool selected) {
        // TODO: Implement category filtering
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: const Color(0xFF3CBFAE).withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF3CBFAE) : Colors.white.withOpacity(0.7),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? const Color(0xFF3CBFAE) : Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required String buildingName,
    required String jobType,
    required String price,
    required String imageUrl,
    required String distance,
    required String scheduledTime,
    required String status,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to job details
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Image Section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 4/3,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            // Info Section
            Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Building Name and Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          buildingName,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3CBFAE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Color(0xFF3CBFAE),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    jobType,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    scheduledTime,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF3CBFAE),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 