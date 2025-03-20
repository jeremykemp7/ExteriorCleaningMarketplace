import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../screens/cleaner/home_screen.dart';
import '../screens/building_owner/home_screen.dart';
import 'navigation_service.dart';
import '../screens/auth/verification_screen.dart';

class AuthService {
  static Future<bool> signIn(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      
      return result.isSignedIn;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  static Future<SignUpResult?> signUp(String email, String password) async {
    try {
      print('Starting sign up process for email: $email');
      final userAttributes = {
        CognitoUserAttributeKey.email: email,
      };
      
      print('Attempting to sign up with Amplify...');
      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      
      print('Sign up result: ${result.isSignUpComplete}');
      print('Next step: ${result.nextStep.signUpStep}');
      return result;
    } on AuthException catch (e) {
      print('AuthException during sign up: ${e.message}');
      print('Auth Exception details: ${e.recoverySuggestion}');
      return null;
    } catch (e) {
      print('General error during sign up: $e');
      return null;
    }
  }

  static Future<bool> confirmSignUp(String email, String confirmationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
      return result.isSignUpComplete;
    } catch (e) {
      print('Error confirming sign up: $e');
      return false;
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(
        username: email,
      );
      NavigationService.showSuccessSnackBar('Password reset instructions sent to your email');
    } catch (e) {
      NavigationService.showErrorSnackBar('Error resetting password: ${e.toString()}');
      rethrow;
    }
  }

  static Future<bool> confirmResetPassword(String email, String code, String newPassword) async {
    try {
      final result = await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: code,
      );
      return result.isPasswordReset;
    } catch (e) {
      print('Error confirming password reset: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      NavigationService.showErrorSnackBar('Error signing out: ${e.toString()}');
    }
  }
} 