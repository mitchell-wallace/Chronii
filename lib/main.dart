import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'layouts/main_layout.dart';
import 'screens/todo_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/login_screen.dart';
import 'screens/note_screen.dart';
import 'utils/window_helper.dart';
import 'services/auth_service.dart';
import 'services/todo_service.dart';
import 'services/timer_service.dart';
import 'services/sync_service.dart';
import 'services/navigation_service.dart';
import 'services/note_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase using platform-specific options from firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // For non-web platforms like Windows, we'll handle persistence differently
  // We won't try to use web-specific features like setPersistence
  if (!kIsWeb && Platform.isWindows) {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.isAnonymous) {
        // Sign out any persisted anonymous user to prevent auto-login
        await FirebaseAuth.instance.signOut();
        debugPrint('Signed out persisted anonymous user on startup');
      }
    } catch (e) {
      debugPrint('Error handling authentication state: $e');
    }
  }
  
  // Only initialize window_manager on desktop platforms
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    // Initialize window_manager using the helper
    await windowManager.ensureInitialized();

    // Configure window options
    WindowOptions windowOptions = const WindowOptions(
      size: Size(480, 720),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'Chronii',
    );

    // Apply window options and show window
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // Initialize the window helper
    final windowHelper = WindowHelper();
    await windowHelper.initWindowManager();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Services
  final AuthService _authService = AuthService();
  final TodoService _todoService = TodoService();
  final TimerService _timerService = TimerService();
  final SyncService _syncService = SyncService();
  final NavigationService _navigationService = NavigationService();
  final NoteService _noteService = NoteService();
  
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    // Initialize services that don't depend on authentication
    await _navigationService.init();
    
    // Disable automatic anonymous authentication on all platforms
    debugPrint('Automatic anonymous authentication is disabled');
    
    // Check if there's a persisted anonymous user and clear it
    final currentUser = _authService.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      debugPrint('Found persisted anonymous user. Signing out to prevent automatic anonymous auth.');
      await _authService.signOut();
    }
    
    // Only initialize data services if the user manually authenticates later
    // We'll delay initialization until authentication to prevent premature Firebase access
    if (_authService.isFullyAuthenticated) {
      // User is already fully authenticated (not anonymous)
      await _todoService.init();
      await _timerService.init();
      await _noteService.init();
    }
    
    // Listen for auth state changes to refresh repositories
    _authService.addListener(_handleAuthStateChanged);
  }
  
  void _handleAuthStateChanged() async {
    final isAuthenticated = _authService.isAuthenticated;
    debugPrint('Auth state changed. User authenticated: $isAuthenticated');
    
    if (isAuthenticated) {
      // Initialize services if they haven't been already
      if (!_todoService.isInitialized) await _todoService.init();
      if (!_timerService.isInitialized) await _timerService.init();
      if (!_noteService.isInitialized) await _noteService.init();
      
      // Refresh repositories to ensure they match the current auth state
      await _todoService.refreshRepository();
      await _timerService.refreshRepository();
      await _noteService.refreshRepository();
    }
  }
  
  @override
  void dispose() {
    // Remove listener
    _authService.removeListener(_handleAuthStateChanged);
    super.dispose();
  }

  // Handle login completion
  void _handleLoginComplete() async {
    // Sync data from local to cloud
    if (_authService.isFullyAuthenticated) {
      await _syncService.synchronizeDataToCloud();
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _todoService),
        ChangeNotifierProvider.value(value: _timerService),
        ChangeNotifierProvider.value(value: _navigationService),
        ChangeNotifierProvider.value(value: _noteService),
        Provider.value(value: _syncService),
      ],
      child: MaterialApp(
        title: 'Chronii',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.light,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, _) {
            return authService.isAuthenticated 
              ? const MyHomePage(title: 'Chronii') 
              : LoginScreen(onLoginComplete: _handleLoginComplete);
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: title,
      tabs: [
        TabItem(
          tab: const Tab(
            icon: Icon(Icons.timer),
            text: 'Timers',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          content: const TimerScreen(),
        ),
        TabItem(
          tab: const Tab(
            icon: Icon(Icons.checklist_rounded),
            text: 'Todo List',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          content: TodoScreen(),
        ),
        TabItem(
          tab: const Tab(
            icon: Icon(Icons.note_alt_outlined),
            text: 'Notes',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          content: const NoteScreen(),
        ),
      ],
    );
  }
}