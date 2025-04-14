import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderType;
  final String receiverId;
  final String receiverName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? propertyId;
  final String? propertyName;
  final String? bidId;
  final double? bidAmount;
  final String? bidStatus;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.receiverId,
    required this.receiverName,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.propertyId,
    this.propertyName,
    this.bidId,
    this.bidAmount,
    this.bidStatus,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      senderName: data['senderName'] as String,
      senderType: data['senderType'] as String,
      receiverId: data['receiverId'] as String,
      receiverName: data['receiverName'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool,
      propertyId: data['propertyId'] as String?,
      propertyName: data['propertyName'] as String?,
      bidId: data['bidId'] as String?,
      bidAmount: (data['bidAmount'] as num?)?.toDouble(),
      bidStatus: data['bidStatus'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderType': senderType,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'bidId': bidId,
      'bidAmount': bidAmount,
      'bidStatus': bidStatus,
    };
  }
} 