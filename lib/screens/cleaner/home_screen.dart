import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import '../../theme.dart';
import '../../services/navigation_service.dart';
import '../../services/auth_service.dart';
import '../welcome_screen.dart';
import 'property_details_screen.dart';
import '../../widgets/app_logo.dart';

class CleanerHomeScreen extends StatefulWidget {
  const CleanerHomeScreen({super.key});

  static void navigate() {
    NavigationService.navigateTo(const CleanerHomeScreen());
  }

  @override
  State<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends State<CleanerHomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _authService = AuthService();
  String _searchQuery = '';
  Stream<QuerySnapshot>? _propertiesStream;
  final _bidPriceController = TextEditingController();
  final _bidNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupPropertiesStream();
  }

  @override
  void dispose() {
    _bidPriceController.dispose();
    _bidNotesController.dispose();
    super.dispose();
  }

  void _setupPropertiesStream() {
    _propertiesStream = _firestore
        .collection('properties')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  void _handleSignOut() async {
    await _authService.signOut();
    if (!mounted) return;
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

  Future<void> _submitBid(String propertyId, String propertyName, double askingPrice) async {
    _bidPriceController.clear();
    _bidNotesController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit Bid for $propertyName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Asking Price: \$${askingPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _bidPriceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Your Bid Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bidNotesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                hintText: 'Add any details about your bid...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit Bid'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        final bidAmount = double.parse(_bidPriceController.text);
        final cleanerId = _auth.currentUser!.uid;
        final cleaner = await _firestore.collection('users').doc(cleanerId).get();
        final cleanerData = cleaner.data() as Map<String, dynamic>;
        
        // Safely handle potentially null names
        final firstName = cleanerData['firstName'] as String? ?? 'Unknown';
        final lastName = cleanerData['lastName'] as String? ?? '';
        final cleanerName = '$firstName $lastName'.trim();

        await _firestore.collection('bids').add({
          'propertyId': propertyId,
          'propertyName': propertyName,
          'cleanerId': cleanerId,
          'cleanerName': cleanerName,
          'cleanerEmail': cleanerData['email'] ?? '',
          'amount': bidAmount,
          'notes': _bidNotesController.text,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'askingPrice': askingPrice,
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bid submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting bid: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPropertyCard(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final name = data['name'] as String;
    final address = data['address'] as String;
    final city = data['city'] as String;
    final state = data['state'] as String;
    final price = (data['price'] as num).toDouble();
    final squareFootage = data['squareFootage'] as num;
    final buildingType = data['buildingType'] as String;
    final description = data['description'] as String;
    final images = List<String>.from(data['images'] ?? []);
    final services = List<String>.from(data['requiredServices'] ?? []);
    final imageUrl = images.isNotEmpty ? images[0] : 'https://picsum.photos/400/300';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('bids')
                      .where('propertyId', isEqualTo: document.id)
                      .orderBy('amount', descending: false)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final lowestBid = (snapshot.data!.docs.first.data() as Map<String, dynamic>)['amount'] as num;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Current: \$${lowestBid.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Content Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name and Type
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    buildingType,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Text(
                    '$address, $city',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    state,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Square Footage
                  Text(
                    '${squareFootage.toString()} sq ft',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => PropertyDetailsScreen.navigate(
                          document.id,
                          data['name'] as String,
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Details'),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () => _submitBid(
                          document.id,
                          data['name'] as String,
                          (data['price'] as num).toDouble(),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Bid'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Properties Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new cleaning opportunities',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const AppLogo(),
        actions: [
          IconButton(
            icon: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .where('participants', arrayContains: _auth.currentUser!.uid)
                  .where('unreadCount', isGreaterThan: 0)
                  .snapshots(),
              builder: (context, snapshot) {
                final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                return Stack(
                  children: [
                    const Icon(Icons.message_outlined),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 8,
                            minHeight: 8,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            onPressed: () => Navigator.pushNamed(context, '/messages'),
            tooltip: 'Messages',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CleanerProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                Text(
                  'Welcome Back, ${_getTimeBasedGreeting()}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find and manage your cleaning jobs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Properties List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _propertiesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final documents = snapshot.data?.docs ?? [];
                final filteredDocs = documents.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final searchLower = _searchQuery.toLowerCase();
                  return data['name'].toString().toLowerCase().contains(searchLower) ||
                         data['address'].toString().toLowerCase().contains(searchLower) ||
                         data['city'].toString().toLowerCase().contains(searchLower) ||
                         data['buildingType'].toString().toLowerCase().contains(searchLower);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState();
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) => _buildPropertyCard(filteredDocs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 