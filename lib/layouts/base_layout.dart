import 'package:flutter/material.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/app_drawer.dart';

/// Base layout with title bar but no tabs
/// Used as a foundation for all screens in the application
class BaseLayout extends StatefulWidget {
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
  
  /// Whether to show the drawer toggle button
  final bool showDrawer;

  const BaseLayout({
    super.key,
    required this.title,
    required this.child,
    this.titleBarColor,
    this.showGradient = true,
    this.actions,
    this.leading,
    this.showDrawer = true,
  });
  
  @override
  State<BaseLayout> createState() => _BaseLayoutState();

}

class _BaseLayoutState extends State<BaseLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = widget.titleBarColor ?? colorScheme.primaryContainer;
    
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomTitleBar(
        title: widget.title,
        backgroundColor: backgroundColor,
        actions: widget.actions,
        leading: widget.leading,
        onMenuPressed: widget.showDrawer ? _openDrawer : null,
      ),
      drawer: widget.showDrawer ? const AppDrawer() : null,
      body: widget.showGradient 
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
            child: widget.child,
          )
        : widget.child,
    );
  }
}
