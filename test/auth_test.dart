import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:com.chronii_time/services/auth_service.dart';
import 'auth_test.mocks.dart';

// Generate mock for FirebaseAuth and User
@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;
  late AuthService authService;
  
  setUp(() {
    // Set up mocks
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    
    // Configure mock behavior
    when(mockUser.isAnonymous).thenReturn(true);
    when(mockUser.uid).thenReturn('test-uid');
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockFirebaseAuth.signInAnonymously()).thenAnswer((_) async => mockUserCredential);
    
    // Mock the auth state changes stream
    final authStateController = StreamController<User?>();
    when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => authStateController.stream);
    
    // Create the auth service with the mock Firebase Auth
    authService = AuthService.withAuth(mockFirebaseAuth);
  });
  
  tearDown(() {
    // Reset the test instance of AuthService
    AuthService.resetInstance();
  });
  
  group('Auth Service Tests', () {
    test('signInAnonymously returns user when successful', () async {
      // Arrange already done in setUp

      // Act
      final user = await authService.signInAnonymously();
      
      // Assert
      expect(user, isNotNull);
      expect(user?.uid, equals('test-uid'));
      expect(user?.isAnonymous, isTrue);
      verify(mockFirebaseAuth.signInAnonymously()).called(1);
    });
    
    test('isAuthenticated returns true when user is authenticated', () async {
      // Arrange - simulate user is signed in
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      // Act - sign in and check authentication state
      await authService.signInAnonymously();
      
      // Assert
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isAnonymous, isTrue);
      expect(authService.isFullyAuthenticated, isFalse);
    });
    
    test('signOut clears current user', () async {
      // Arrange - simulate user is signed in
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {
        // Simulate sign out by returning null for currentUser
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        return;
      });
      
      // Act - sign in then sign out
      await authService.signInAnonymously();
      await authService.signOut();
      
      // Assert - verify signOut was called and user is cleared
      verify(mockFirebaseAuth.signOut()).called(1);
      expect(authService.isAuthenticated, isFalse);
    });
  });
}
