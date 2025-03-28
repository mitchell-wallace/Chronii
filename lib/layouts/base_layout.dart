import 'package:flutter/material.dart';
import '../widgets/custom_title_bar.dart';

/// Base layout with title bar but no tabs
/// Used as a foundation for all screens in the application
class BaseLayout extends StatelessWidget {
  /// Title displayed in the title bar
  final String title;
  
  /// Background color for the title bar
  final Color? titleBarColor;
  
  /// Content of the screen
  final Widget child;
  
  /// Whether to show a gradient background
  final bool showGradient;
  
  /// Additional widgets to display in the title bar (right side)
  final List<Widget>? actions;
  
  /// Additional widget to display in the title bar (left side)
  final Widget? leading;

  const BaseLayout({
    super.key,
    required this.title,
    required this.child,
    this.titleBarColor,
    this.showGradient = true,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = titleBarColor ?? colorScheme.primaryContainer;
    
    return Scaffold(
      appBar: CustomTitleBar(
        title: title,
        backgroundColor: backgroundColor,
        actions: actions,
        leading: leading,
      ),
      body: showGradient 
        ? Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  backgroundColor.withOpacity(0.3),
                  Colors.white,
                ],
              ),
            ),
            child: child,
          )
        : child,
    );
  }
}
