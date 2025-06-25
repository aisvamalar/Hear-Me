// lib/services/auth_service.dart - Enhanced version with better error handling
import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();

  // Timeout duration for network operations
  static const Duration _timeoutDuration = Duration(seconds: 30);


  User? get currentUser => _auth.currentUser;

  // Add this method to handle search history updates
  Future<void> updateSearchHistory(String userId, String searchTerm) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      await userDocRef.update({
        'searchHistory': FieldValue.arrayUnion([{
          'term': searchTerm,
          'timestamp': FieldValue.serverTimestamp(),
        }])
      });
    } catch (e) {
      print('Error updating search history: $e');
      // Handle error appropriately - maybe throw or log
    }
  }

  // You might also want to get search history
  Future<List<String>> getSearchHistory(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();

      if (data != null && data['searchHistory'] != null) {
        final List<dynamic> history = data['searchHistory'];
        return history.map((item) => item['term'] as String).toList();
      }

      return [];
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  /// Check if device has internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('No connectivity detected');
        return false;
      }

      // Additional check by trying to lookup a host
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('Internet connection check failed: $e');
      return false;
    }
  }

  /// Enhanced sign in with email and password with better error handling
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      // Check internet connectivity first
      if (!await _hasInternetConnection()) {
        throw AuthException('no-internet', 'No internet connection available');
      }

      print('Attempting to sign in with email: $email');

      // Wrap the Firebase auth call with additional error handling
      UserCredential? credential;
      try {
        credential = await _auth
            .signInWithEmailAndPassword(
          email: email.toLowerCase().trim(),
          password: password,
        )
            .timeout(_timeoutDuration);
      } catch (e) {
        // Handle the specific PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List') ||
            e.toString().contains('subtype')) {
          print('PigeonUserDetails error detected, retrying...');
          // Wait a moment and retry
          await Future.delayed(const Duration(milliseconds: 500));
          credential = await _auth
              .signInWithEmailAndPassword(
            email: email.toLowerCase().trim(),
            password: password,
          )
              .timeout(_timeoutDuration);
        } else {
          rethrow;
        }
      }

      print('Sign-in successful for user: ${credential.user!.uid}');
      final user = credential.user!;
      final userModel = await getUserData(user.uid);

      // Return UserModel if available, otherwise create a minimal one
      if (userModel != null) {
        print('User data retrieved from Firestore: ${userModel.toMap()}');
        return userModel;
      } else {
        print('No Firestore data found, creating minimal UserModel');
        return UserModel(
          uid: user.uid,
          email: user.email ?? email,
          displayName: user.displayName ?? email.split('@')[0],
          createdAt: user.metadata.creationTime ?? DateTime.now(),
        );
      }
    } on TimeoutException {
      print('Sign-in timed out');
      throw AuthException('timeout', 'Request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(e.code, _getAuthErrorMessage(e.code));
    } on SocketException {
      print('SocketException occurred');
      throw AuthException('network-error', 'Network error. Please check your connection.');
    } catch (e) {
      print('Unexpected error: $e');

      // Handle PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List') ||
          e.toString().contains('subtype')) {
        throw AuthException('auth-plugin-error',
            'Authentication plugin error. Please update your app and try again.');
      }

      if (e is AuthException) rethrow;
      throw AuthException('unknown', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Enhanced sign up with email, password, and display name
  Future<UserModel?> signUpWithEmail(
      String email,
      String password,
      String displayName,
      ) async {
    try {
      // Check internet connectivity first
      if (!await _hasInternetConnection()) {
        throw AuthException('no-internet', 'No internet connection available');
      }

      print('Attempting to sign up with email: $email');

      // Wrap the Firebase auth call with additional error handling
      UserCredential? credential;
      try {
        credential = await _auth
            .createUserWithEmailAndPassword(
          email: email.toLowerCase().trim(),
          password: password,
        )
            .timeout(_timeoutDuration);
      } catch (e) {
        // Handle the specific PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List') ||
            e.toString().contains('subtype')) {
          print('PigeonUserDetails error detected during signup, retrying...');
          // Wait a moment and retry
          await Future.delayed(const Duration(milliseconds: 500));
          credential = await _auth
              .createUserWithEmailAndPassword(
            email: email.toLowerCase().trim(),
            password: password,
          )
              .timeout(_timeoutDuration);
        } else {
          rethrow;
        }
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      // Create user document in Firestore
      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      print('Creating Firestore document for user: ${user.uid}');
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(user.toMap())
          .timeout(_timeoutDuration);

      print('Sign-up successful for user: ${user.uid}');
      return user;
    } on TimeoutException {
      print('Sign-up timed out');
      throw AuthException('timeout', 'Request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign-up: ${e.code} - ${e.message}');
      throw AuthException(e.code, _getAuthErrorMessage(e.code));
    } on SocketException {
      print('SocketException occurred during sign-up');
      throw AuthException('network-error', 'Network error. Please check your connection.');
    } catch (e) {
      print('Unexpected error during sign-up: $e');

      // Handle PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List') ||
          e.toString().contains('subtype')) {
        throw AuthException('auth-plugin-error',
            'Authentication plugin error. Please update your app and try again.');
      }

      if (e is AuthException) rethrow;
      throw AuthException('unknown', 'An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Enhanced Google Sign-In with better error handling
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Check internet connectivity first
      if (!await _hasInternetConnection()) {
        throw AuthException('no-internet', 'No internet connection available');
      }

      print('Attempting Google sign-in');
      // Sign out from Google first to ensure account selection
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(_timeoutDuration);

      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        throw AuthException('sign-in-cancelled', 'Google sign-in was cancelled');
      }

      print('Google account selected: ${googleUser.email}');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication
          .timeout(_timeoutDuration);

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential with retry logic
      UserCredential? userCredential;
      try {
        userCredential = await _auth
            .signInWithCredential(credential)
            .timeout(_timeoutDuration);
      } catch (e) {
        // Handle the specific PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails') ||
            e.toString().contains('List') ||
            e.toString().contains('subtype')) {
          print('PigeonUserDetails error detected during Google sign-in, retrying...');
          // Wait a moment and retry
          await Future.delayed(const Duration(milliseconds: 500));
          userCredential = await _auth
              .signInWithCredential(credential)
              .timeout(_timeoutDuration);
        } else {
          rethrow;
        }
      }

      final User? user = userCredential.user;

      if (user != null) {
        print('Firebase authentication successful for user: ${user.uid}');
        // Check if user already exists in Firestore
        UserModel? existingUser = await getUserData(user.uid);
        if (existingUser == null) {
          // Create new user document in Firestore
          final newUser = UserModel(
            uid: user.uid,
            email: user.email!,
            displayName: user.displayName ?? '',
            photoURL: user.photoURL,
            createdAt: DateTime.now(),
          );

          print('Creating Firestore document for new Google user: ${user.uid}');
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap())
              .timeout(_timeoutDuration);

          return newUser;
        } else {
          // Update existing user with latest info from Google
          final updatedUser = existingUser.copyWith(
            displayName: user.displayName ?? existingUser.displayName,
            photoURL: user.photoURL ?? existingUser.photoURL,
          );

          print('Updating Firestore document for existing Google user: ${user.uid}');
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({
            'displayName': updatedUser.displayName,
            'photoURL': updatedUser.photoURL,
            'lastSignInAt': FieldValue.serverTimestamp(),
          })
              .timeout(_timeoutDuration);

          return updatedUser;
        }
      }

      print('No user returned from Google sign-in');
      return null;
    } on TimeoutException {
      print('Google sign-in timed out');
      throw AuthException('timeout', 'Request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google sign-in: ${e.code} - ${e.message}');
      throw AuthException(e.code, _getAuthErrorMessage(e.code));
    } on SocketException {
      print('SocketException occurred during Google sign-in');
      throw AuthException('network-error', 'Network error. Please check your connection.');
    } catch (e) {
      print('Unexpected error during Google sign-in: $e');

      // Handle PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List') ||
          e.toString().contains('subtype')) {
        throw AuthException('auth-plugin-error',
            'Authentication plugin error. Please update your app and try again.');
      }

      if (e is AuthException) rethrow;
      throw AuthException('google-signin-failed', 'Google sign-in failed: ${e.toString()}');
    }
  }

  // ... rest of your methods remain the same ...

  Future<void> signOut() async {
    try {
      print('Attempting to sign out');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]).timeout(_timeoutDuration);
      print('Sign-out successful');
    } on TimeoutException {
      print('Sign-out timed out, attempting individual sign-outs');
      try {
        await _auth.signOut();
      } catch (e) {
        print('Firebase sign out failed: $e');
      }
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Google sign out failed: $e');
      }
    } catch (e) {
      print('Unexpected error during sign-out: $e');
      throw AuthException('signout-failed', 'Sign out failed: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!await _hasInternetConnection()) {
        throw AuthException('no-internet', 'No internet connection available');
      }

      print('Sending password reset email to: $email');
      await _auth
          .sendPasswordResetEmail(email: email)
          .timeout(_timeoutDuration);
      print('Password reset email sent successfully');
    } on TimeoutException {
      print('Password reset timed out');
      throw AuthException('timeout', 'Request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      throw AuthException(e.code, _getAuthErrorMessage(e.code));
    } on SocketException {
      print('SocketException occurred during password reset');
      throw AuthException('network-error', 'Network error. Please check your connection.');
    } catch (e) {
      print('Unexpected error during password reset: $e');
      if (e is AuthException) rethrow;
      throw AuthException('unknown', 'Password reset failed: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      print('Fetching user data from Firestore for uid: $uid');
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_timeoutDuration);

      if (doc.exists && doc.data() != null) {
        print('User data found in Firestore: ${doc.data()}');
        return UserModel.fromMap(doc.data()!);
      }
      print('No user data found in Firestore for uid: $uid');
      return null;
    } on TimeoutException {
      print('Firestore data retrieval timed out for uid: $uid');
      throw AuthException('timeout', 'Failed to retrieve user data: Request timed out');
    } on FirebaseException catch (e) {
      print('FirebaseException during user data retrieval: ${e.message}');
      throw AuthException('firestore-error', 'Failed to get user data: ${e.message}');
    } catch (e) {
      print('Unexpected error during user data retrieval: $e');
      throw AuthException('unknown', 'Failed to get user data: ${e.toString()}');
    }
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email but different sign-in method.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'auth-plugin-error':
        return 'Authentication plugin error. Please update your app and try again.';
      default:
        return 'An error occurred. Please try again later.';
    }
  }
}

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  const AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException: $message';
}