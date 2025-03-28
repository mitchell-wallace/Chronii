import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';
import 'layouts/main_layout.dart';
import 'screens/counter_screen.dart';
import 'screens/todo_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/login_screen.dart';
import 'utils/window_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  // Flag to determine if the user is logged in
  bool _isLoggedIn = false;

  // Handle login completion
  void _handleLoginComplete() {
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: _isLoggedIn ? const MyHomePage(title: 'Chronii') : LoginScreen(onLoginComplete: _handleLoginComplete),
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
            icon: Icon(Icons.add_circle_outline),
            text: 'Counter',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          content: const CounterScreen(),
        ),
        TabItem(
          tab: const Tab(
            icon: Icon(Icons.checklist_rounded),
            text: 'Todo List',
            iconMargin: EdgeInsets.only(bottom: 4),
          ),
          content: const TodoScreen(),
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
  }
}