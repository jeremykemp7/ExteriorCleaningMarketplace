import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  StorageService() : _storage = FirebaseStorage.instance;

  // Upload a profile image for a user
  Future<String> uploadProfileImage(String userId, XFile imageFile) async {
    try {
      print('Starting profile image upload for user: $userId');
      final String fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');

      // Read the file as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      final metadata = SettableMetadata(
        contentType: _getContentType(imageFile),
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalFilename': imageFile.name
        },
      );

      final uploadTask = ref.putData(imageBytes, metadata);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      print('Upload completed successfully');
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Get file extension for uploads
  String _getFileExtension(XFile file) {
    if (kIsWeb) {
      final name = file.name;
      return name.contains('.') ? name.split('.').last.toLowerCase() : 'jpg';
    } else {
      return path.extension(file.path).replaceAll('.', '').toLowerCase();
    }
  }

  // Get content type for uploads
  String _getContentType(XFile file) {
    final fileName = file.name.toLowerCase();
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      return 'image/png';
    } else if (fileName.endsWith('.gif')) {
      return 'image/gif';
    } else if (fileName.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'application/octet-stream';
  }

  // Upload a property image
  Future<String> uploadPropertyImage(String userId, XFile imageFile) async {
    try {
      print('Starting property image upload for user: $userId');
      final String fileName = '${_uuid.v4()}.jpg';
      final ref = _storage.ref().child('properties/$userId/images/$fileName');

      // Read the file as bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      final metadata = SettableMetadata(
        contentType: _getContentType(imageFile),
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'originalFilename': imageFile.name
        },
      );

      final uploadTask = ref.putData(imageBytes, metadata);

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      print('Upload completed successfully');
      
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading property image: $e');
      rethrow;
    }
  }

  // Upload a service completion image
  Future<String> uploadServiceImage(String serviceId, XFile imageFile) async {
    try {
      final String fileName = '${_uuid.v4()}.${_getFileExtension(imageFile)}';
      final Reference ref = _storage.ref().child('services/$serviceId/images/$fileName');
      
      UploadTask uploadTask;
      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        final contentType = _getContentType(imageFile);
        uploadTask = ref.putData(
          bytes,
          SettableMetadata(contentType: contentType),
        );
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error in uploadServiceImage: $e');
      throw Exception('Failed to upload service image');
    }
  }

  // Delete an image by its full path
  Future<void> deleteImage(String imagePath) async {
    try {
      final Reference ref = _storage.ref().child(imagePath);
      await ref.delete();
    } catch (e) {
      print('Error in deleteImage: $e');
      throw Exception('Failed to delete image');
    }
  }

  // Get the download URL for an image by its path
  Future<String> getImageUrl(String imagePath) async {
    try {
      final Reference ref = _storage.ref().child(imagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error in getImageUrl: $e');
      throw Exception('Failed to get image URL');
    }
  }

  // Get the download URL for a design asset
  Future<String> getDesignAssetUrl(String assetName) async {
    try {
      print('Starting to fetch design asset: $assetName');
      final ref = _storage.ref().child('design/assets/$assetName');
      print('Storage reference created for path: design/assets/$assetName');
      
      // Use the standard download URL for both web and mobile
      final url = await ref.getDownloadURL();
      print('Successfully retrieved download URL: $url');
      return url;
    } catch (e) {
      print('Error in getDesignAssetUrl: $e');
      rethrow;
    }
  }

  // Upload a design asset (for admin use)
  Future<String> uploadDesignAsset(XFile file, String assetPath) async {
    try {
      print('Starting design asset upload for ${file.name} to $assetPath');
      
      final contentType = _getContentType(file);
      print('Content type determined: $contentType');

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'uploaded_by': 'design_asset_uploader',
          'original_filename': file.name,
        },
        cacheControl: 'public, max-age=3600',
        contentLanguage: 'en',
        contentDisposition: 'inline',
      );

      final ref = _storage.ref().child(assetPath);
      
      Uint8List fileBytes = await file.readAsBytes();
      print('File bytes read, size: ${fileBytes.length} bytes');

      final uploadTask = ref.putData(fileBytes, metadata);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      await uploadTask;
      print('Upload completed successfully');

      final downloadUrl = await ref.getDownloadURL();
      print('Download URL generated: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      print('Error uploading design asset: $e');
      rethrow;
    }
  }

  Future<String> getProfileImageUrl(String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final ref = _storage.ref().child('users/$userId/profile/$fileName');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting profile image URL: $e');
      rethrow;
    }
  }
} 