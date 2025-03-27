import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls> with WindowListener {
  bool _isFullScreen = false;
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _init();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _init() async {
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