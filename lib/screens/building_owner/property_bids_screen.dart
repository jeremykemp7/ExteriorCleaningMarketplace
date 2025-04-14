import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/navigation_service.dart';
import '../chat/chat_screen.dart';

class PropertyBidsScreen extends StatefulWidget {
  final String propertyId;
  final String propertyName;

  const PropertyBidsScreen({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  static void navigate(String propertyId, String propertyName) {
    final context = NavigationService.context;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PropertyBidsScreen(
            propertyId: propertyId,
            propertyName: propertyName,
          ),
        ),
      );
    }
  }

  @override
  State<PropertyBidsScreen> createState() => _PropertyBidsScreenState();
}

class _PropertyBidsScreenState extends State<PropertyBidsScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<bool> _showConfirmationDialog(String action, String cleanerName, double amount) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm ${action.toLowerCase()} bid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to ${action.toLowerCase()} the bid from:'),
              const SizedBox(height: 8),
              Text(
                cleanerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Amount: \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (action == 'Accept') const Text(
                '\nThis will mark the property as unavailable and reject all other bids.',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: action == 'Accept' ? Colors.green : Colors.red,
              ),
              child: Text(action),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<bool> _showReopenConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Reopen Property'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to reopen ${widget.propertyName} for bidding?'),
              const SizedBox(height: 16),
              const Text(
                'This will:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• Mark the property as available'),
              const Text('• Cancel the currently accepted bid'),
              const Text('• Allow new bids to be submitted'),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Reopen Property'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _reopenProperty() async {
    if (!await _showReopenConfirmationDialog()) {
      return;
    }

    try {
      final batch = _firestore.batch();
      
      // Update property status
      final propertyRef = _firestore.collection('properties').doc(widget.propertyId);
      batch.update(propertyRef, {
        'status': 'available',
        'acceptedBidId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Get the accepted bid and mark it as cancelled
      final acceptedBid = await _firestore
          .collection('bids')
          .where('propertyId', isEqualTo: widget.propertyId)
          .where('status', isEqualTo: 'accepted')
          .get();
      
      if (acceptedBid.docs.isNotEmpty) {
        batch.update(acceptedBid.docs.first.reference, {
          'status': 'cancelled',
          'updatedAt': FieldValue.serverTimestamp(),
          'cancellationReason': 'Property reopened for bidding',
        });
      }
      
      await batch.commit();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property reopened for bidding'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reopening property: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateBidStatus(String bidId, String newStatus) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      final bidRef = _firestore.collection('bids').doc(bidId);
      
      // Get the bid data first
      final bidDoc = await bidRef.get();
      final bidData = bidDoc.data() as Map<String, dynamic>;
      final cleanerId = bidData['cleanerId'] as String;
      final cleanerName = bidData['cleanerName'] as String;
      final amount = (bidData['amount'] as num).toDouble();
      
      // Update the current bid
      batch.update(bidRef, {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Get the current user (owner) data
      final ownerId = FirebaseAuth.instance.currentUser!.uid;
      final ownerDoc = await _firestore.collection('users').doc(ownerId).get();
      final ownerData = ownerDoc.data() as Map<String, dynamic>;
      final ownerName = '${ownerData['firstName']} ${ownerData['lastName']}'.trim();
      
      // Update chat metadata if it exists
      final chatId = _getChatId(ownerId, cleanerId);
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      
      if (chatDoc.exists) {
        final statusMessage = newStatus == 'accepted' 
          ? 'Your bid of \$${amount.toStringAsFixed(2)} has been accepted!'
          : 'Your bid of \$${amount.toStringAsFixed(2)} has been rejected.';

        // Add status message to chat
        batch.set(
          chatRef.collection('messages').doc(),
          {
            'content': statusMessage,
            'senderId': ownerId,
            'senderName': ownerName,
            'senderType': 'building_owner',
            'receiverId': cleanerId,
            'receiverName': cleanerName,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'propertyId': widget.propertyId,
            'propertyName': widget.propertyName,
            'bidId': bidId,
            'bidAmount': amount,
            'bidStatus': newStatus,
          },
        );

        // Update chat metadata
        batch.update(chatRef, {
          'bidStatus': newStatus,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
          'lastMessage': statusMessage,
          'unreadCount': FieldValue.increment(1),
        });
      }

      if (newStatus == 'accepted') {
        // Update the property status to unavailable
        final propertyRef = _firestore.collection('properties').doc(widget.propertyId);
        batch.update(propertyRef, {
          'status': 'unavailable',
          'acceptedBidId': bidId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Get all other pending bids for this property and reject them
        final otherBids = await _firestore
            .collection('bids')
            .where('propertyId', isEqualTo: widget.propertyId)
            .where('status', isEqualTo: 'pending')
            .where(FieldPath.documentId, isNotEqualTo: bidId)
            .get();
        
        for (final doc in otherBids.docs) {
          final rejectedAmount = (doc.data()['amount'] as num).toDouble();
          batch.update(doc.reference, {
            'status': 'rejected',
            'updatedAt': FieldValue.serverTimestamp(),
            'rejectionReason': 'Another bid was accepted',
          });
          
          // Update chat metadata for rejected bids if chat exists
          final rejectedCleaner = doc.data()['cleanerId'] as String;
          final rejectedCleanerName = doc.data()['cleanerName'] as String;
          final rejectedChatId = _getChatId(ownerId, rejectedCleaner);
          final rejectedChatDoc = await _firestore.collection('chats').doc(rejectedChatId).get();
          
          if (rejectedChatDoc.exists) {
            final rejectionMessage = 'Your bid of \$${rejectedAmount.toStringAsFixed(2)} has been rejected - Another bid was accepted.';
            
            // Add rejection message to chat
            batch.set(
              rejectedChatDoc.reference.collection('messages').doc(),
              {
                'content': rejectionMessage,
                'senderId': ownerId,
                'senderName': ownerName,
                'senderType': 'building_owner',
                'receiverId': rejectedCleaner,
                'receiverName': rejectedCleanerName,
                'timestamp': FieldValue.serverTimestamp(),
                'isRead': false,
                'propertyId': widget.propertyId,
                'propertyName': widget.propertyName,
                'bidId': doc.id,
                'bidAmount': rejectedAmount,
                'bidStatus': 'rejected',
              },
            );

            batch.update(rejectedChatDoc.reference, {
              'bidStatus': 'rejected',
              'lastMessageTimestamp': FieldValue.serverTimestamp(),
              'lastMessage': rejectionMessage,
              'unreadCount': FieldValue.increment(1),
            });
          }
        }
      }

      // Commit all changes
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid ${newStatus.toLowerCase()} successfully'),
          backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
        ),
      );

      // If bid was accepted, navigate back to the dashboard
      if (newStatus == 'accepted') {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bid status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Widget _buildBidCard(DocumentSnapshot bid) {
    final data = bid.data() as Map<String, dynamic>;
    final status = data['status'] as String;
    final amount = (data['amount'] as num).toDouble();
    final askingPrice = (data['askingPrice'] as num).toDouble();
    final cleanerName = data['cleanerName'] as String;
    final cleanerEmail = data['cleanerEmail'] as String;
    final notes = data['notes'] as String;
    final timestamp = (data['createdAt'] as Timestamp).toDate();

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cleanerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      cleanerEmail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
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
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bid Amount',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: amount < askingPrice ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asking Price',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '\$${askingPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(notes),
            ],
            const SizedBox(height: 16),
            Text(
              'Submitted ${timestamp.toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserId: data['cleanerId'] as String,
                            otherUserName: cleanerName,
                            propertyId: widget.propertyId,
                            propertyName: widget.propertyName,
                            bidId: bid.id,
                            bidAmount: amount,
                            bidStatus: status,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Message Cleaner',
                  ),
                  TextButton(
                    onPressed: () async {
                      if (await _showConfirmationDialog('Reject', cleanerName, amount)) {
                        await _updateBidStatus(bid.id, 'rejected');
                      }
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (await _showConfirmationDialog('Accept', cleanerName, amount)) {
                        await _updateBidStatus(bid.id, 'accepted');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
            if (status == 'accepted') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.message_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            otherUserId: data['cleanerId'] as String,
                            otherUserName: cleanerName,
                            propertyId: widget.propertyId,
                            propertyName: widget.propertyName,
                            bidId: bid.id,
                            bidAmount: amount,
                            bidStatus: status,
                          ),
                        ),
                      );
                    },
                    tooltip: 'Message Cleaner',
                  ),
                  ElevatedButton(
                    onPressed: _reopenProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Reopen for Bidding'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bids for ${widget.propertyName}'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gavel_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Bids Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for cleaners to submit their bids',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) => _buildBidCard(bids[index]),
          );
        },
      ),
    );
  }
} 