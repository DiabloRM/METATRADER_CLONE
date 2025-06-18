import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // Add clientId for web support
    clientId:
        '1899486761-u3rst67sidthtuv2ucl4j3n3i66v8jqv.apps.googleusercontent.com', // Replace with your actual client ID
  );

  // Get current user
  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _googleSignIn.currentUser != null;

  // Check if Google Sign-In is available on this platform
  Future<bool> isAvailable() async {
    try {
      // Check platform
      if (kIsWeb) {
        debugPrint('Google Sign-In: Running on web platform');
        return true;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('Google Sign-In: Running on Android platform');
        // For Android, we need to check if Google Services is configured
        return false; // Temporarily disable for Android until properly configured
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint('Google Sign-In: Running on iOS platform');
        // For iOS, we need to check if Google Sign-In is configured
        return false; // Temporarily disable for iOS until properly configured
      } else {
        debugPrint(
            'Google Sign-In: Unsupported platform: $defaultTargetPlatform');
        return false;
      }
    } catch (e) {
      debugPrint('Google Sign-In not available: $e');
      return false;
    }
  }

  // Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      debugPrint('Starting Google Sign-In process...');

      // First check if available on this platform
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        throw Exception('Google Sign-In is not available on this platform');
      }

      // Check if already signed in
      try {
        if (_googleSignIn.currentUser != null) {
          debugPrint(
              'User already signed in: ${_googleSignIn.currentUser!.email}');
          return _googleSignIn.currentUser;
        }
      } catch (e) {
        debugPrint('Error checking current user: $e');
      }

      // Attempt to sign in
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account != null) {
        debugPrint('Google Sign-In successful: ${account.email}');
        return account;
      } else {
        debugPrint('Google Sign-In was cancelled by user');
        return null;
      }
    } on PlatformException catch (e) {
      debugPrint('Google Sign-In PlatformException: ${e.code} - ${e.message}');

      // Handle specific platform errors
      switch (e.code) {
        case 'channel-error':
          debugPrint('Channel error detected. This might be due to:');
          debugPrint('1. Missing Google Services configuration');
          debugPrint('2. Platform not properly configured');
          debugPrint('3. Running on unsupported platform');
          throw Exception(
              'Google Sign-In not available on this platform. Please use email/password login.');

        case 'sign_in_canceled':
          debugPrint('Sign-in was cancelled by user');
          return null;

        case 'sign_in_failed':
          debugPrint('Sign-in failed: ${e.message}');
          throw Exception('Google Sign-In failed: ${e.message}');

        default:
          debugPrint('Unknown platform error: ${e.code}');
          throw Exception('Google Sign-In error: ${e.message}');
      }
    } catch (error) {
      debugPrint('Google Sign-In general error: $error');
      throw Exception('Google Sign-In error: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('Starting Google Sign-Out...');
      await _googleSignIn.signOut();
      debugPrint('Google Sign-Out successful');
    } catch (error) {
      debugPrint('Google Sign-Out error: $error');
      rethrow;
    }
  }

  // Get user details
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      final GoogleSignInAccount? account = _googleSignIn.currentUser;
      if (account == null) return null;

      return {
        'id': account.id,
        'email': account.email,
        'displayName': account.displayName,
        'photoUrl': account.photoUrl,
        'serverAuthCode': account.serverAuthCode,
      };
    } catch (error) {
      debugPrint('Get user details error: $error');
      return null;
    }
  }

  // Convert Google account to User model
  User? convertToUser(GoogleSignInAccount? account) {
    if (account == null) return null;

    return User(
      login: account.id,
      email: account.email,
      name: account.displayName ?? 'Google User',
      phone: null,
      country: null,
      city: null,
      zipCode: null,
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  // Authenticate with your backend using Google token
  Future<Map<String, dynamic>> authenticateWithBackend(
      GoogleSignInAccount account) async {
    try {
      debugPrint('Authenticating with backend for user: ${account.email}');

      // Get auth tokens
      final GoogleSignInAuthentication auth = await account.authentication;
      debugPrint('Got authentication tokens');

      // Send to your backend
      final response = await http.post(
        Uri.parse('http://localhost:8000/PHP/auth/google_signin.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_token': auth.idToken,
          'access_token': auth.accessToken,
          'email': account.email,
          'name': account.displayName,
          'photo_url': account.photoUrl,
        }),
      );

      debugPrint('Backend response status: ${response.statusCode}');
      debugPrint('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Backend authentication successful');
        return data;
      } else {
        debugPrint(
            'Backend authentication failed with status: ${response.statusCode}');
        throw Exception(
            'Backend authentication failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('Backend authentication error: $error');
      rethrow;
    }
  }
}
