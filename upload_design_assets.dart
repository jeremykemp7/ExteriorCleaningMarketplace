import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import '../lib/services/storage_service.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final storageService = StorageService();
  
  // Upload the Lucid Bots logo
  try {
    final logoFile = XFile('assets/lucid_bots_logo.png');
    final url = await storageService.uploadDesignAsset('lucid_bots_logo.png', logoFile);
    print('Logo uploaded successfully: $url');
  } catch (e) {
    print('Error uploading logo: $e');
  }
} 