// lib/viewmodels/auth_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:music_recommender/models/user_model.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String _errorMessage = '';
  UserModel? _userModel; // Store UserModel for additional data

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => isSignedIn;
  bool get isSignedIn => _user != null;
  String get userDisplayName => _userModel?.displayName ?? _user?.displayName ?? _user?.email?.split('@')[0] ?? 'User';
  String get userEmail => _userModel?.email ?? _user?.email ?? '';
  String get userPhotoURL => _userModel?.photoURL ?? _user?.photoURL ?? '';

  AuthViewModel() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserModel(user.uid); // Fetch UserModel on auth state change
        _logAuthenticationSuccess('Auth State Changed', user);
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserModel(String uid) async {
    try {
      _userModel = await _authService.getUserData(uid); // Use public method
      notifyListeners();
    } catch (e) {
      print('Failed to fetch user model: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _logAuthenticationSuccess(String method, User user) {
    print('🎉 AUTHENTICATION SUCCESS - $method');
    print('┌─────────────────────────────────────┐');
    print('│ User Authentication Details         │');
    print('├─────────────────────────────────────┤');
    print('│ Method: $method');
    print('│ UID: ${user.uid}');
    print('│ Email: ${user.email ?? 'Not provided'}');
    print('│ Display Name: ${user.displayName ?? 'Not set'}');
    print('│ Photo URL: ${user.photoURL ?? 'Not set'}');
    print('│ Email Verified: ${user.emailVerified}');
    print('│ Creation Time: ${user.metadata.creationTime}');
    print('│ Last Sign In: ${user.metadata.lastSignInTime}');
    print('└─────────────────────────────────────┘');
  }

  void _logAuthenticationError(String method, String error) {
    print('❌ AUTHENTICATION ERROR - $method');
    print('┌─────────────────────────────────────┐');
    print('│ Authentication Failed               │');
    print('├─────────────────────────────────────┤');
    print('│ Method: $method');
    print('│ Error: $error');
    print('│ Timestamp: ${DateTime.now()}');
    print('└─────────────────────────────────────┘');
  }

  // Sign up with email and password
  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError('');

      print('🔄 Starting Sign Up Process...');
      print('Email: $email');
      print('Name: $name');

      // Use AuthService for sign-up
      final userModel = await _authService.signUpWithEmail(email, password, name);
      if (userModel != null) {
        _user = _auth.currentUser;
        _userModel = userModel;
        _logAuthenticationSuccess('Email Sign Up', _user!);
        return true;
      }
      _setError('Sign-up failed. Please try again.');
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      _logAuthenticationError('Email Sign Up', '${e.message} (${e.code})');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _logAuthenticationError('Email Sign Up', e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError('');

      print('🔄 Starting Sign In Process...');
      print('Email: $email');

      // Use AuthService for sign-in
      final userModel = await _authService.signInWithEmail(email, password);
      if (userModel != null) {
        _user = _auth.currentUser;
        _userModel = userModel;
        _logAuthenticationSuccess('Email Sign In', _user!);
        return true;
      }
      _setError('Invalid login credentials. Please check your email and password.');
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      _logAuthenticationError('Email Sign In', '${e.message} (${e.code})');
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _logAuthenticationError('Email Sign In', e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError('');

      print('🔄 Starting Google Sign In Process...');

      // Use AuthService for Google sign-in
      final userModel = await _authService.signInWithGoogle();
      if (userModel != null) {
        _user = _auth.currentUser;
        _userModel = userModel;
        _logAuthenticationSuccess('Google Sign In', _user!);
        return true;
      }
      _setError('Google sign-in failed. Please try again.');
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      _logAuthenticationError('Google Sign In', '${e.message} (${e.code})');
      return false;
    } catch (e) {
      _setError('Failed to sign in with Google. Please try again.');
      _logAuthenticationError('Google Sign In', e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔄 Starting Sign Out Process...');

      await _authService.signOut();
      _user = null;
      _userModel = null;

      print('✅ Sign Out Successful');
      print('┌─────────────────────────────────────┐');
      print('│ User Successfully Signed Out        │');
      print('│ Timestamp: ${DateTime.now()}');
      print('└─────────────────────────────────────┘');

      notifyListeners();
    } catch (e) {
      print('❌ Sign Out Error: $e');
      _setError('Failed to sign out. Please try again.');
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError('');

      await _authService.resetPassword(email);

      print('✅ Password Reset Email Sent');
      print('Email: $email');

      return true;
    } on AuthException catch (e) {
      _setError(e.message);
      _logAuthenticationError('Password Reset', '${e.message} (${e.code})');
      return false;
    } catch (e) {
      _setError('Failed to send reset email. Please try again.');
      _logAuthenticationError('Password Reset', e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
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
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'invalid-credential':
        return 'Invalid login credentials. Please check your email and password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}