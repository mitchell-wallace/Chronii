import 'package:flutter/material.dart';
import 'timer_service.dart';

/// A service that handles navigation between tabs and creating timers from todos
class NavigationService extends ChangeNotifier {
  // Singleton pattern
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Current tab index
  int _currentIndex = 0;
  
  // TabController that will be set by the main app
  TabController? _tabController;
  
  // Timer service for creating timers
  final TimerService _timerService = TimerService();
  bool _initialized = false;
  
  // Initialize the service
  Future<void> init() async {
    if (!_initialized) {
      await _timerService.init();
      _initialized = true;
    }
  }
  
  // Set the tab controller
  void setTabController(TabController controller) {
    _tabController = controller;
  }
  
  // Navigate to a specific tab
  void navigateToTab(int index) {
    _currentIndex = index;
    _tabController?.animateTo(index);
    notifyListeners();
  }
  
  // Navigate to timer tab and create a timer
  Future<void> createTimerFromTodo(String todoTitle) async {
    // Wait for init if needed
    if (!_initialized) {
      await init();
    }
    
    // Create the timer
    await _timerService.addTimer(todoTitle);
    
    // Navigate to timer tab
    navigateToTab(2);
  }
}
