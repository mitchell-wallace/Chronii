// This is a widget test for anonymous authentication in the Chronii app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:com.chronii_time/screens/login_screen.dart';
import 'package:com.chronii_time/screens/timer_screen.dart';
import 'package:com.chronii_time/layouts/main_layout.dart';
import 'package:com.chronii_time/services/auth_service.dart';
import 'package:com.chronii_time/services/todo_service.dart';
import 'package:com.chronii_time/services/timer_service.dart';
import 'package:com.chronii_time/services/sync_service.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, User])
import 'widget_test.mocks.dart';

// Mock classes for services that depend on Firebase
class MockTodoService extends TodoService {
  @override
  Future<void> init() async {
    // No-op for testing
  }
  
  @override
  Future<void> refreshRepository() async {
    // No-op for testing
  }
}

class MockTimerService extends TimerService {
  @override
  Future<void> init() async {
    // No-op for testing
  }
  
  @override
  Future<void> refreshRepository() async {
    // No-op for testing
  }
}

class MockSyncService extends SyncService {
  @override
  Future<void> synchronizeDataToCloud() async {
    // No-op for testing
  }
}

// Mock for AuthService to override Firebase interaction
class MockAuthService extends ChangeNotifier implements AuthService {
  final MockUser _mockUser;
  bool _isAnonymous = false;
  
  MockAuthService(this._mockUser);
  
  @override
  User? get currentUser => _isAnonymous ? _mockUser : null;
  
  @override
  bool get isAuthenticated => _isAnonymous;
  
  @override
  bool get isAnonymous => _isAnonymous;
  
  @override
  bool get isFullyAuthenticated => false;
  
  @override
  Future<User?> signInAnonymously() async {
    // Simulate anonymous sign-in
    _isAnonymous = true;
    notifyListeners();
    return _mockUser;
  }
  
  @override
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    return null; // Not used in this test
  }
  
  @override
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    return null; // Not used in this test
  }
  
  @override
  Future<User?> linkAnonymousAccountWithEmailAndPassword(String email, String password) async {
    return null; // Not used in this test
  }
  
  @override
  Future<void> signOut() async {
    _isAnonymous = false;
    notifyListeners();
  }
  
  @override
  Future<bool> resetPassword(String email) async {
    return false; // Not used in this test
  }
  
  @override
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    return false; // Not used in this test
  }
}

// Simple widget that mimics the app's structure for testing
class TestableApp extends StatelessWidget {
  final AuthService authService;
  final TodoService todoService;
  final TimerService timerService;
  final SyncService syncService;
  final VoidCallback? onLoginComplete;

  const TestableApp({
    super.key,
    required this.authService,
    required this.todoService,
    required this.timerService,
    required this.syncService,
    this.onLoginComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<TodoService>.value(value: todoService),
        ChangeNotifierProvider<TimerService>.value(value: timerService),
        Provider<SyncService>.value(value: syncService),
      ],
      child: MaterialApp(
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            if (authService.isAuthenticated) {
              return MainLayout(
                title: 'Chronii',
                tabs: [
                  TabItem(
                    tab: const Tab(
                      icon: Icon(Icons.add_circle_outline),
                      text: 'Counter',
                      iconMargin: EdgeInsets.only(bottom: 4),
                    ),
                    content: const SizedBox(), // Placeholder for Counter
                  ),
                  TabItem(
                    tab: const Tab(
                      icon: Icon(Icons.checklist_rounded),
                      text: 'Todo List',
                      iconMargin: EdgeInsets.only(bottom: 4),
                    ),
                    content: const SizedBox(), // Placeholder for Todo
                  ),
                  TabItem(
                    tab: const Tab(
                      icon: Icon(Icons.timer),
                      text: 'Timers',
                      iconMargin: EdgeInsets.only(bottom: 4),
                    ),
                    content: const TimerScreen(),
                  ),
                ],
              );
            } else {
              return LoginScreen(
                onLoginComplete: onLoginComplete ?? () {},
              );
            }
          },
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockUser mockUser;
  late MockAuthService mockAuthService;
  late MockTodoService mockTodoService;
  late MockTimerService mockTimerService;
  late MockSyncService mockSyncService;
  
  setUp(() {
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('mock-uid-123');
    when(mockUser.isAnonymous).thenReturn(true);
    
    mockAuthService = MockAuthService(mockUser);
    mockTodoService = MockTodoService();
    mockTimerService = MockTimerService();
    mockSyncService = MockSyncService();
  });
  
  testWidgets('Anonymous login navigates to main app with Timers tab', 
    (WidgetTester tester) async {
      bool loginCompleted = false;
      
      // Build our test app
      await tester.pumpWidget(
        TestableApp(
          authService: mockAuthService,
          todoService: mockTodoService,
          timerService: mockTimerService,
          syncService: mockSyncService,
          onLoginComplete: () {
            loginCompleted = true;
          },
        ),
      );
      
      // Verify we start on login screen
      expect(find.text('Continue without account'), findsOneWidget);
      
      // Tap anonymous login button
      await tester.tap(find.widgetWithText(OutlinedButton, 'Continue without account'));
      await tester.pump(); // Process callback
      
      // Verify login complete callback was called
      expect(loginCompleted, true);
      
      // Trigger a frame to update with the new auth state
      await tester.pump();
      await tester.pumpAndSettle(); // Wait for any animations
      
      // Now we should be on the main screen with tabs
      expect(find.text('Timers'), findsOneWidget);
      
      // Tap the Timers tab
      await tester.tap(find.text('Timers'));
      await tester.pumpAndSettle();
      
      // Verify we're on the timer screen
      expect(find.byType(TimerScreen), findsOneWidget);
    }
  );
}
