import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  bool _initialized = false;
  
  Future<void> initialize() async {
    if (!kIsWeb || _initialized) return;
    
    try {
      final messaging = FirebaseMessaging.instance;
      final isSupported = await messaging.isSupported();
      
      if (isSupported) {
        _initialized = true;
      }
    } catch (e) {
      // Silently fail - messaging is optional
      print('Messaging not available: $e');
    }
  }
  
  Future<void> requestPermission() async {
    if (!kIsWeb) return;
    
    try {
      final messaging = FirebaseMessaging.instance;
      if (await messaging.isSupported()) {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          final token = await messaging.getToken(
            vapidKey: 'BMFkOhrVDgRhW7KhelXnbGxRov-Q4DR7K79rhgYYDLEhA_XpibnRXMuDMh6HFnyhnqUp_CRA4j1R9UrWjKIOD6M',
          );
          print('FCM Token: $token');
        }
      }
    } catch (e) {
      // Silently fail - messaging is optional
      print('Permission request failed: $e');
    }
  }
} 