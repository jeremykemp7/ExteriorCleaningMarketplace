import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _functions = FirebaseFunctions.instance;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final fcmToken = userDoc.data()?['fcmToken'] as String?;

      if (fcmToken != null) {
        await _functions.httpsCallable('sendPushNotification').call({
          'token': fcmToken,
          'title': title,
          'body': body,
          'data': {
            'type': 'message',
            'senderId': _auth.currentUser?.uid,
          },
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Get chat ID between two users (consistent regardless of who initiates)
  String getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Send a message
  Future<void> sendMessage({
    required String receiverId,
    required String receiverName,
    required String content,
    String? propertyId,
    String? propertyName,
    String? bidId,
    double? bidAmount,
    String? bidStatus,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final chatId = getChatId(currentUser.uid, receiverId);
    final userProfile = await _firestore.collection('users').doc(currentUser.uid).get();
    final userData = userProfile.data() as Map<String, dynamic>;
    final firstName = userData['firstName'] as String? ?? 'Unknown';
    final lastName = userData['lastName'] as String? ?? '';
    final senderName = '$firstName $lastName'.trim();
    final userType = userData['userType'] as String? ?? 'unknown';

    // Create message
    final message = ChatMessage(
      id: '', // Will be set by Firestore
      senderId: currentUser.uid,
      senderName: senderName,
      senderType: userType,
      receiverId: receiverId,
      receiverName: receiverName,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      propertyId: propertyId,
      propertyName: propertyName,
      bidId: bidId,
      bidAmount: bidAmount,
      bidStatus: bidStatus,
    );

    // Start a batch write
    final batch = _firestore.batch();

    // Add message to messages subcollection
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.toFirestore());

    // Update chat metadata
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.set(chatRef, {
      'lastMessage': content,
      'lastMessageTimestamp': Timestamp.now(),
      'participants': [currentUser.uid, receiverId],
      'participantNames': [senderName, receiverName],
      'participantTypes': [userType, null], // Will be updated when other user sends a message
      'unreadCount': FieldValue.increment(1),
      'propertyId': propertyId,
      'propertyName': propertyName,
      'bidId': bidId,
      'bidAmount': bidAmount,
      'bidStatus': bidStatus,
    }, SetOptions(merge: true));

    // Commit the batch
    await batch.commit();

    // Get receiver's FCM tokens
    final receiverDoc = await _firestore.collection('users').doc(receiverId).get();
    final receiverData = receiverDoc.data();
    if (receiverData != null && receiverData.containsKey('fcmTokens')) {
      final fcmTokens = List<String>.from(receiverData['fcmTokens'] ?? []);
      
      // Send notification to each token
      for (final token in fcmTokens) {
        await _functions.httpsCallable('sendPushNotification').call({
          'token': token,
          'title': senderName,
          'body': content,
          'data': {
            'chatId': chatId,
            'senderId': currentUser.uid,
            'type': 'message',
          },
        });
      }
    }
  }

  // Get messages stream for a chat
  Stream<QuerySnapshot> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final chatId = getChatId(currentUser.uid, otherUserId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get all chats for current user
  Stream<QuerySnapshot> getChats() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final chatId = getChatId(currentUser.uid, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);
    
    // Reset unread count
    await chatRef.update({
      'unreadCount': 0,
    });

    // Mark all messages as read
    final messages = await chatRef
        .collection('messages')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in messages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Delete a message
  Future<void> deleteMessage(String otherUserId, String messageId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    final chatId = getChatId(currentUser.uid, otherUserId);
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
} 