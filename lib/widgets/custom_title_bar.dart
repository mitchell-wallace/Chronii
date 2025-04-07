import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final double height;
  final VoidCallback? onMenuPressed;

  const CustomTitleBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.leading,
    this.actions,
    this.bottom,
    this.height = 50.0,
    this.onMenuPressed,
  });

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();

  @override
  Size get preferredSize {
    final bool isDesktopPlatform = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final double bottomHeight = bottom?.preferredSize.height ?? 0;
    final double titleBarHeight = isDesktopPlatform ? height : kToolbarHeight;
    return Size.fromHeight(titleBarHeight + bottomHeight);
  }
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _isMaximized = false;
  bool _isFullScreen = false;
  bool _isHovering = false;

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
    
    _isMaximized = await windowManager.isMaximized();
    _isFullScreen = await windowManager.isFullScreen();
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
    if (!isDesktop) {
      // On non-desktop platforms, we just render a regular app bar
      return AppBar(
        title: Text(widget.title),
        backgroundColor: widget.backgroundColor,
        actions: widget.actions,
        leading: widget.leading,
        bottom: widget.bottom,
      );
    }

    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final backgroundColor = widget.backgroundColor ?? colorScheme.primaryContainer;
    final foregroundColor = colorScheme.onPrimaryContainer;

    return Material(
      color: backgroundColor,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom title bar with draggable area
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: Container(
              height: widget.height,
              color: _isHovering ? backgroundColor.withOpacity(0.95) : backgroundColor,
              child: Stack(
                children: [
                  // Draggable area covering the entire title bar
                  Positioned.fill(
                    child: GestureDetector(
                      onPanStart: (_) {
                        windowManager.startDragging();
                      },
                      onDoubleTap: () async {
                        if (_isMaximized) {
                          await windowManager.unmaximize();
                        } else {
                          await windowManager.maximize();
                        }
                      },
                      // Transparent container to capture gestures
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                  
                  // Content of the title bar (will appear above the draggable area)
                  Row(
                    children: [
                      // Hamburger menu button
                      if (widget.onMenuPressed != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onMenuPressed,
                            child: SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(
                                Icons.menu,
                                size: 20,
                                color: foregroundColor,
                              ),
                            ),
                          ),
                        ),
                      
                      // App icon/logo area (left side)
                      if (widget.leading != null) widget.leading!,
                      
                      // Title area (middle)
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: foregroundColor,
                            ),
                          ),
                        ),
                      ),
                      
                      // Custom actions if provided
                      if (widget.actions != null) 
                        ...widget.actions!,
                      
                      // Window control buttons
                      // These will receive events because they're above the draggable area in the Stack
                      WindowControlButtons(
                        isMaximized: _isMaximized,
                        backgroundColor: backgroundColor,
                        foregroundColor: foregroundColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Include the bottom widget if provided (like TabBar)
          if (widget.bottom != null) widget.bottom!,
        ],
      ),
    );
  }
}

class WindowControlButtons extends StatelessWidget {
  final bool isMaximized;
  final Color backgroundColor;
  final Color foregroundColor;

  const WindowControlButtons({
    super.key,
    required this.isMaximized,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWindowButton(
          icon: Icons.minimize,
          tooltip: 'Minimize',
          onPressed: () async {
            await windowManager.minimize();
          },
        ),
        _buildWindowButton(
          icon: isMaximized ? Icons.crop_square : Icons.crop_7_5,
          tooltip: isMaximized ? 'Restore' : 'Maximize',
          onPressed: () async {
            if (isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
        ),
        _buildWindowButton(
          icon: Icons.close,
          tooltip: 'Close',
          onPressed: () async {
            await windowManager.close();
          },
          isCloseButton: true,
        ),
      ],
    );
  }

  Widget _buildWindowButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isCloseButton = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        hoverColor: isCloseButton 
            ? Colors.red.withOpacity(0.6) 
            : backgroundColor.withOpacity(0.8),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              icon,
              size: 20,
              color: foregroundColor,
            ),
          ),
        ),
      ),
    );
  }
} 