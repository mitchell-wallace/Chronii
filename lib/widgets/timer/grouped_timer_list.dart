import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import '../../utils/timer_grouping_util.dart';
import 'group_header.dart';
import 'timer_card.dart';

/// Enum for timer view modes
enum TimerViewMode {
  /// Flat list view (no grouping)
  flat,
  
  /// Grouped by day
  day,
  
  /// Grouped by week
  week,
}

/// Widget for displaying a grouped list of timers
class GroupedTimerList extends StatefulWidget {
  /// List of timers to display
  final List<TaskTimer> timers;
  
  /// Current time for calculating durations
  final DateTime currentTime;
  
  /// Set of selected timer IDs
  final Set<String> selectedTimerIds;
  
  /// The current view mode
  final TimerViewMode viewMode;
  
  /// Callback when a timer's toggle button is pressed
  final Function(String) onToggleTimer;
  
  /// Callback when a timer is selected
  final Function(String) onSelectTimer;
  
  /// Callback when a timer is deleted
  final Function(String) onDeleteTimer;
  
  /// Callback when a timer is updated
  final Function(TaskTimer) onUpdateTimer;

  /// Constructor
  const GroupedTimerList({
    super.key,
    required this.timers,
    required this.currentTime,
    required this.selectedTimerIds,
    required this.viewMode,
    required this.onToggleTimer,
    required this.onSelectTimer,
    required this.onDeleteTimer,
    required this.onUpdateTimer,
  });

  @override
  State<GroupedTimerList> createState() => _GroupedTimerListState();
}

class _GroupedTimerListState extends State<GroupedTimerList> with SingleTickerProviderStateMixin {
  // Set of expanded group keys
  final Set<DateTime> _expandedGroups = {};
  
  // Animation controller for expand/collapse animations
  late AnimationController _animationController;
  
  // Map of animations for each group
  final Map<DateTime, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Initially expand all groups
    _initializeExpandedGroups();
  }
  
  @override
  void didUpdateWidget(GroupedTimerList oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If view mode changed, reinitialize expanded groups
    if (oldWidget.viewMode != widget.viewMode) {
      _initializeExpandedGroups();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Initialize all groups as expanded
  void _initializeExpandedGroups() {
    _expandedGroups.clear();
    
    // Get the appropriate groups based on the view mode
    final groups = _getGroups();
    
    // Add all group keys to expanded set
    _expandedGroups.addAll(groups.keys);
    
    // Create animations for each group
    _createAnimations(groups.keys.toList());
  }
  
  /// Create animations for all groups
  void _createAnimations(List<DateTime> groupKeys) {
    _animations.clear();
    
    for (final key in groupKeys) {
      _animations[key] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
    }
    
    // Ensure animation controller is at the end (all expanded)
    _animationController.value = 1.0;
  }
  
  /// Toggle a group's expanded state
  void _toggleGroup(DateTime groupKey) {
    setState(() {
      if (_expandedGroups.contains(groupKey)) {
        _expandedGroups.remove(groupKey);
      } else {
        _expandedGroups.add(groupKey);
      }
    });
  }
  
  /// Get groups based on the current view mode
  Map<DateTime, TimerGroup> _getGroups() {
    switch (widget.viewMode) {
      case TimerViewMode.day:
        return TimerGroupingUtil.groupByDay(widget.timers);
      case TimerViewMode.week:
        return TimerGroupingUtil.groupByWeek(widget.timers);
      case TimerViewMode.flat:
        // For flat view, we use a single group with current date as key
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        return {
          today: TimerGroup(
            groupKey: today,
            timers: List.from(widget.timers)..sort((a, b) => b.startTime.compareTo(a.startTime)),
            totalDuration: widget.timers.fold(
              Duration.zero,
              (total, timer) => total + timer.getDuration(widget.currentTime),
            ),
            title: 'All Timers',
          ),
        };
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get groups based on the view mode
    final groups = _getGroups();
    
    // Sort group keys (newest first)
    final sortedKeys = TimerGroupingUtil.sortGroupKeys(groups.keys.toList());
    
    // No timers case
    if (groups.isEmpty) {
      return const Center(
        child: Text('No timers to display'),
      );
    }
    
    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: EdgeInsets.zero, // No padding to match the existing UI
      itemBuilder: (context, index) {
        final groupKey = sortedKeys[index];
        final group = groups[groupKey]!;
        final isExpanded = _expandedGroups.contains(groupKey);
        
        // If we're in flat view, don't show the header
        if (widget.viewMode == TimerViewMode.flat) {
          return Column(
            children: _buildTimerItems(group.timers),
          );
        }
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Group header
            GroupHeader(
              title: group.title,
              totalDuration: group.totalDuration,
              timerCount: group.count,
              isExpanded: isExpanded,
              onToggleExpanded: () => _toggleGroup(groupKey),
            ),
            
            // Timers in this group (only visible if expanded)
            AnimatedCrossFade(
              firstChild: Column(children: _buildTimerItems(group.timers)),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isExpanded 
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
            
            // Add a divider if not the last group
            if (index < sortedKeys.length - 1)
              const Divider(height: 1),
          ],
        );
      },
    );
  }
  
  /// Build a list of timer card widgets from a list of timers
  List<Widget> _buildTimerItems(List<TaskTimer> timers) {
    return timers.map((timer) {
      return TimerCard(
        key: ValueKey(timer.id),
        timer: timer,
        isSelected: widget.selectedTimerIds.contains(timer.id),
        currentTime: widget.currentTime,
        onToggle: () => widget.onToggleTimer(timer.id),
        onSelect: () => widget.onSelectTimer(timer.id),
        onDelete: () => widget.onDeleteTimer(timer.id),
        onUpdate: widget.onUpdateTimer,
      );
    }).toList();
  }
} 