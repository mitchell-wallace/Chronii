import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import '../widgets/counter_view.dart';
import '../widgets/todo_list_view.dart';
import '../widgets/custom_title_bar.dart';
import 'timer_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recreate the tab controller to ensure its length matches the number of tabs
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: CustomTitleBar(
        title: widget.title,
        backgroundColor: colorScheme.primaryContainer,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onPrimaryContainer.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.add_circle_outline),
              text: 'Counter',
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: Icon(Icons.checklist_rounded),
              text: 'Todo List',
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
            Tab(
              icon: Icon(Icons.timer),
              text: 'Timers',
              iconMargin: EdgeInsets.only(bottom: 4),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              Colors.white,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            // Counter Tab
            CounterView(),
            // Todo List Tab
            TodoListView(),
            // Timer Tab - Now it will inherit the gradient background
            TimerScreen(),
          ],
        ),
      ),
    );
  }
} 