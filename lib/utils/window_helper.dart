import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

class WindowHelper with WindowListener {
  // Singleton instance
  static final WindowHelper _instance = WindowHelper._internal();
  
  factory WindowHelper() {
    return _instance;
  }
  
  WindowHelper._internal();
  
  // Check if running on desktop
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  // Initialize the window manager
  Future<void> initWindowManager() async {
    if (!isDesktop) return;
    
    await windowManager.ensureInitialized();
    
    // Set prevent close to true so we can handle window closing
    await windowManager.setPreventClose(true);
    windowManager.addListener(this);
  }
  
  // Dispose resources
  void dispose() {
    if (!isDesktop) return;
    
    windowManager.removeListener(this);
  }
  
  // Override window close handler to show confirmation dialog
  @override
  void onWindowClose() async {
    if (!isDesktop) return;
    
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      // Get the current context - you need to pass this from your app
      BuildContext? context = _getActiveContext();
      if (context != null) {
        _showCloseConfirmationDialog(context);
      } else {
        // If no context available, just close the window
        await windowManager.destroy();
      }
    }
  }
  
  // Get the active context from the top-level navigator
  BuildContext? _getActiveContext() {
    // This is a simple approach, you may need a more robust solution
    // to get the current context in a real app
    try {
      return WidgetsBinding.instance.focusManager.primaryFocus?.context;
    } catch (e) {
      return null;
    }
  }
  
  // Show a dialog to confirm closing the app
  void _showCloseConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the application?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                if (isDesktop) {
                  await windowManager.destroy(); // Close the window
                }
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
  
  // Show confirm dialog for closing the window
  Future<bool> showCloseConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Exit'),
          content: const Text('Are you sure you want to exit the application?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't close
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Close the app
              },
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
} 