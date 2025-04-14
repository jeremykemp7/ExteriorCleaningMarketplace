import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/navigation_service.dart';
import '../chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  static void navigate(String propertyId, String propertyName) {
    final context = NavigationService.context;
    if (context != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyDetailsScreen(
            propertyId: propertyId,
            propertyName: propertyName,
          ),
        ),
      );
    }
  }

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  int _currentImageIndex = 0;
  final _bidPriceController = TextEditingController();
  final _bidNotesController = TextEditingController();

  @override
  void dispose() {
    _bidPriceController.dispose();
    _bidNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitBid(num askingPrice, String propertyName) async {
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
          'propertyId': widget.propertyId,
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
        Navigator.pop(context); // Return to previous screen after successful bid
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

  Widget _buildImageCarousel(List<String> images) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemBuilder: (context, index) => Image.network(
              images[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentImageIndex
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceChip(String service) {
    return Chip(
      label: Text(service),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBidHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bids')
          .where('propertyId', isEqualTo: widget.propertyId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final bids = snapshot.data?.docs ?? [];

        if (bids.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('No bids yet'),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bids.length,
          itemBuilder: (context, index) {
            final bid = bids[index].data() as Map<String, dynamic>;
            final amount = (bid['amount'] as num).toDouble();
            final status = bid['status'] as String;
            final timestamp = (bid['createdAt'] as Timestamp).toDate();

            Color statusColor;
            switch (status) {
              case 'accepted':
                statusColor = Colors.green;
                break;
              case 'rejected':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.orange;
            }

            return ListTile(
              title: Text('\$${amount.toStringAsFixed(2)}'),
              subtitle: Text(timestamp.toString().split('.')[0]),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.propertyName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('properties').doc(widget.propertyId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
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
          final ownerId = data['ownerId'] as String;
          final ownerName = data['ownerName'] as String? ?? 'Property Owner';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (images.isNotEmpty) _buildImageCarousel(images),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        buildingType,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '\$${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.message_outlined),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              otherUserId: ownerId,
                                              otherUserName: ownerName,
                                              propertyId: widget.propertyId,
                                              propertyName: widget.propertyName,
                                            ),
                                          ),
                                        );
                                      },
                                      tooltip: 'Message Owner',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '$address, $city, $state',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${squareFootage.toString()} sq ft',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(description),
                            const SizedBox(height: 16),
                            Text(
                              'Required Services',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: services.map(_buildServiceChip).toList(),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Bid History',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildBidHistory(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final data = _firestore.collection('properties').doc(widget.propertyId).get();
          data.then((doc) {
            if (doc.exists) {
              final propertyData = doc.data() as Map<String, dynamic>;
              _submitBid(
                propertyData['price'] as num,
                propertyData['name'] as String,
              );
            }
          });
        },
        icon: const Icon(Icons.gavel),
        label: const Text('Place Bid'),
      ),
    );
  }
} 