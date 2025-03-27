import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_page.dart';
import 'utils/window_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window_manager using the helper
  await windowManager.ensureInitialized();

  // Configure window options
  WindowOptions windowOptions = const WindowOptions(
    size: Size(480, 720),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Task Manager',
  );

  // Apply window options and show window
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Initialize the window helper
  final windowHelper = WindowHelper();
  await windowHelper.initWindowManager();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
          secondary: Colors.indigo.shade300,
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      home: const MyHomePage(title: 'Task Manager'),
    );
  }
} 