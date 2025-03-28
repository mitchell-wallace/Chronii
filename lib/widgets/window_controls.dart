import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  bool _isFullScreen = false;
  bool _isMaximized = false;
  
  // Check if running on desktop
  bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  void initState() {
    super.initState();
    if (isDesktop) {
      windowManager.addListener(this);
      _init();
    }
  }

  @override
  void dispose() {
    if (isDesktop) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  void _init() async {
    if (!isDesktop) return;
    
    _isFullScreen = await windowManager.isFullScreen();
    _isMaximized = await windowManager.isMaximized();
    setState(() {});
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't render anything if not on desktop
    if (!isDesktop) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.minimize),
          onPressed: () async {
            await windowManager.minimize();
          },
          tooltip: 'Minimize',
        ),
        IconButton(
          icon: Icon(_isMaximized ? Icons.crop_square : Icons.crop_7_5),
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
          tooltip: _isMaximized ? 'Restore' : 'Maximize',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            await windowManager.close();
          },
          tooltip: 'Close',
        ),
      ],
    );
  }
} 