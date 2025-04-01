import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'base_layout.dart';

/// Main application layout with tabs
/// Extends BaseLayout to include a tab bar system
class MainLayout extends StatefulWidget {
  /// Title displayed in the title bar
  final String title;
  
  /// Background color for the title bar
  final Color? titleBarColor;
  
  /// List of tabs to display
  final List<TabItem> tabs;
  
  /// Default tab index to show
  final int initialTabIndex;
  
  /// Whether to show a gradient background
  final bool showGradient;
  
  /// Additional widgets to display in the title bar (right side)
  final List<Widget>? actions;
  
  /// Additional widget to display in the title bar (left side)
  final Widget? leading;

  const MainLayout({
    super.key,
    required this.title,
    required this.tabs,
    this.titleBarColor,
    this.initialTabIndex = 0,
    this.showGradient = true,
    this.actions,
    this.leading,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  late TabController _tabController;
  final NavigationService _navigationService = NavigationService();

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    
    // Register with navigation service and add listener
    _navigationService.setTabController(_tabController);
    _tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    // Not needed since we're using a simpler approach
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Recreate the tab controller
    _tabController = TabController(
      length: widget.tabs.length,
      vsync: this,
      initialIndex: _tabController.index.clamp(0, widget.tabs.length - 1),
    );
    
    // Update the navigation service
    _navigationService.setTabController(_tabController);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BaseLayout(
      title: widget.title,
      titleBarColor: widget.titleBarColor,
      showGradient: widget.showGradient,
      actions: widget.actions,
      leading: widget.leading,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: widget.titleBarColor ?? colorScheme.primaryContainer,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onPrimaryContainer.withOpacity(0.7),
              tabs: widget.tabs.map((tab) => tab.tab).toList(),
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: widget.tabs.map((tab) => tab.content).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for tab items
class TabItem {
  /// The tab widget (typically a Tab with icon and text)
  final Widget tab;
  
  /// The content to display when this tab is selected
  final Widget content;

  const TabItem({
    required this.tab,
    required this.content,
  });
}
