import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String userType,
    required String firstName,
    required String lastName,
  }) async {
    try {
      print('Creating user with email and password...'); // Debug log
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Sending email verification...'); // Debug log
      // Send email verification
      await userCredential.user!.sendEmailVerification();

      print('Creating user profile in Firestore...'); // Debug log
      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'userType': userType,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'emailVerified': false,
        'profileImageUrl': null,  // Initialize profile image URL as null
      });

      print('User created successfully'); // Debug log
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error during signup: ${e.code} - ${e.message}'); // Debug log
      throw _handleAuthError(e);
    } catch (e) {
      print('Unexpected error during signup: $e'); // Debug log
      throw e.toString();
    }
  }

  // Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthService: Attempting sign in for $email'); // Debug log
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthService: Initial sign in successful'); // Debug log

      // Reload user to get latest verification status
      print('AuthService: Reloading user to get latest status'); // Debug log
      await userCredential.user!.reload();
      final user = _auth.currentUser;

      print('AuthService: User email verified: ${user?.emailVerified}'); // Debug log

      // Check if email is verified
      if (user == null || !user.emailVerified) {
        print('AuthService: Email not verified, throwing exception'); // Debug log
        throw CustomAuthException(
          'Please verify your email before signing in. Check your inbox for the verification link.',
        );
      }

      // Update user profile in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'lastSignInTime': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified,
      });

      print('AuthService: Sign in process complete'); // Debug log
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('AuthService: Firebase Auth Error - ${e.code}: ${e.message}'); // Debug log
      throw _handleAuthError(e);
    } catch (e) {
      print('AuthService: Unexpected Error - $e'); // Debug log
      throw e.toString();
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('getUserProfile: No user logged in');
        return null;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      print('getUserProfile: Retrieved data: $data');
      print('getUserProfile: Profile image URL: ${data?['profileImageUrl']}');
      return data;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      await _firestore.collection('users').doc(user.uid).update({
        ...data,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating user profile: $e');
      throw 'Failed to update profile';
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Handle Firebase Auth errors
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'Please enter a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class CustomAuthException implements Exception {
  final String message;
  CustomAuthException(this.message);

  @override
  String toString() => message;
} 