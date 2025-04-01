import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service that manages user authentication state
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth;
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  
  // Private constructor for singleton
  AuthService._internal() : _auth = FirebaseAuth.instance {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
  
  // Factory constructor to return the singleton
  factory AuthService() {
    return _instance;
  }
  
  /// The current authenticated user, or null if not authenticated
  User? get currentUser => _auth.currentUser;
  
  /// Whether the user is authenticated (including anonymous)
  bool get isAuthenticated => currentUser != null;
  
  /// Whether the user is fully authenticated (not anonymous)
  bool get isFullyAuthenticated => currentUser != null && !currentUser!.isAnonymous;
  
  /// Whether the user is in anonymous mode
  bool get isAnonymous => currentUser?.isAnonymous ?? false;
  
  /// Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      return null;
    }
  }
  
  /// Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      return null;
    }
  }
  
  /// Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error registering with email and password: $e');
      return null;
    }
  }
  
  /// Link anonymous account to email and password
  Future<User?> linkAnonymousAccountWithEmailAndPassword(
    String email, 
    String password
  ) async {
    if (currentUser == null || !currentUser!.isAnonymous) {
      return null;
    }
    
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      
      final userCredential = await currentUser!.linkWithCredential(credential);
      notifyListeners();
      return userCredential.user;
    } catch (e) {
      debugPrint('Error linking anonymous account: $e');
      return null;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
  
  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }
  
  /// Update user profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    if (currentUser == null) return false;
    
    try {
      await currentUser!.updateDisplayName(displayName);
      await currentUser!.updatePhotoURL(photoURL);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}
