import 'package:flutter/material.dart';
import 'dart:async';
import '../models/timer_model.dart';
import '../services/timer_service.dart';
import '../utils/timer_grouping_util.dart';
import '../widgets/base/base_empty_state.dart';
import '../widgets/timer/timer_card.dart';
import '../widgets/timer/timer_form.dart';
import '../widgets/timer/timer_summary.dart';
import '../widgets/timer/group_header.dart';

/// Screen for managing task timers
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Timer service
  final TimerService _timerService = TimerService();
  
  // Selected timer IDs
  final Set<String> _selectedTimerIds = {};
  
  // UI update timer
  Timer? _uiUpdateTimer;
  
  // Current time for duration calculations
  DateTime _currentTime = DateTime.now();
  
  // Loading state
  bool _isLoading = true;
  
  // Expanded groups state
  final Set<DateTime> _expandedDayGroups = {};
  final Set<DateTime> _expandedWeekGroups = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize the timer service
    _initializeTimerService();
    
    // Start a periodic timer to update the UI
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  Future<void> _initializeTimerService() async {
    setState(() {
      _isLoading = true;
    });
    
    await _timerService.init();
    
    setState(() {
      _isLoading = false;
      
      // Initially expand current week and today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeekStart = TimerGroupingUtil.getStartOfWeek(now);
      
      _expandedDayGroups.add(today);
      _expandedWeekGroups.add(thisWeekStart);
    });
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    super.dispose();
  }

  // Create a new timer
  Future<void> _createTimer(String name) async {
    if (name.trim().isEmpty) return;
    
    await _timerService.addTimer(name);
    setState(() {}); // Refresh UI
  }

  // Toggle timer running state
  Future<void> _toggleTimer(String timerId) async {
    await _timerService.toggleTimer(timerId);
    setState(() {}); // Refresh UI
  }

  // Toggle timer selection
  void _toggleTimerSelection(String timerId) {
    setState(() {
      if (_selectedTimerIds.contains(timerId)) {
        _selectedTimerIds.remove(timerId);
      } else {
        _selectedTimerIds.add(timerId);
      }
    });
  }

  // Deselect all timers
  void _deselectAllTimers() {
    setState(() {
      _selectedTimerIds.clear();
    });
  }

  // Delete timer
  Future<void> _deleteTimer(String timerId) async {
    await _timerService.deleteTimer(timerId);
    setState(() {
      _selectedTimerIds.remove(timerId);
    });
  }

  // Delete all selected timers
  Future<void> _deleteSelectedTimers() async {
    // Show confirmation dialog
    final shouldDelete = await _showDeleteConfirmationDialog();
    if (shouldDelete != true) return;
    
    // Delete all selected timers
    for (final timerId in _selectedTimerIds.toList()) {
      await _timerService.deleteTimer(timerId);
    }
    
    setState(() {
      _selectedTimerIds.clear();
    });
  }
  
  // Show confirmation dialog before deleting multiple timers
  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Timers'),
        content: Text(
          'Are you sure you want to delete ${_selectedTimerIds.length} '
          '${_selectedTimerIds.length == 1 ? 'timer' : 'timers'}?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Update timer
  Future<void> _updateTimer(TaskTimer updatedTimer) async {
    await _timerService.updateTimer(updatedTimer);
    setState(() {}); // Refresh UI
  }
  
  // Toggle day group expanded state
  void _toggleDayGroup(DateTime date) {
    setState(() {
      if (_expandedDayGroups.contains(date)) {
        _expandedDayGroups.remove(date);
      } else {
        _expandedDayGroups.add(date);
      }
    });
  }
  
  // Toggle week group expanded state
  void _toggleWeekGroup(DateTime weekStart) {
    setState(() {
      if (_expandedWeekGroups.contains(weekStart)) {
        _expandedWeekGroups.remove(weekStart);
      } else {
        _expandedWeekGroups.add(weekStart);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timers = _timerService.timers;
    
    // Only calculate total duration if we have selected timers and service is initialized
    final totalDuration = _selectedTimerIds.isEmpty ? 
        Duration.zero : 
        _timerService.calculateTotalDuration(_selectedTimerIds.toList());
    
    // Main content with padding on top, left, and right only
    Widget mainContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: TimerForm(onCreateTimer: _createTimer),
        ),
        
        const SizedBox(height: 16),
        
        // Hierarchical timer list with weeks containing days
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : timers.isEmpty
                  ? const BaseEmptyState(
                      icon: Icons.timer_outlined,
                      message: 'No timers yet',
                      subMessage: 'Create a timer to get started',
                    )
                  : _buildNestedTimerList(timers),
        ),
      ],
    );
    
    return Column(
      children: [
        // Main content
        Expanded(child: mainContent),
        
        // Selected timers summary (full width, no padding)
        if (_selectedTimerIds.isNotEmpty)
          TimerSummary(
            selectedCount: _selectedTimerIds.length,
            totalDuration: totalDuration,
            onDeselectAll: _deselectAllTimers,
            onDeleteAll: _deleteSelectedTimers,
          ),
      ],
    );
  }
  
  Widget _buildNestedTimerList(List<TaskTimer> timers) {
    if (timers.isEmpty) {
      return const Center(child: Text('No timers to display'));
    }
    
    // Group timers by day
    final dayGroups = TimerGroupingUtil.groupByDay(timers);
    final sortedDayKeys = TimerGroupingUtil.sortGroupKeys(dayGroups.keys.toList());
    
    // Group days by their week
    final weekToDays = TimerGroupingUtil.groupDaysByWeek(sortedDayKeys);
    final sortedWeekKeys = TimerGroupingUtil.sortGroupKeys(weekToDays.keys.toList());
    
    // Get weekly totals
    final weekTotals = <DateTime, Duration>{};
    for (final weekStart in sortedWeekKeys) {
      final daysInWeek = weekToDays[weekStart]!;
      Duration weekTotal = Duration.zero;
      
      for (final dayKey in daysInWeek) {
        weekTotal += dayGroups[dayKey]!.totalDuration;
      }
      
      weekTotals[weekStart] = weekTotal;
    }
    
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: sortedWeekKeys.length,
      itemBuilder: (context, weekIndex) {
        final weekStart = sortedWeekKeys[weekIndex];
        final daysInWeek = weekToDays[weekStart]!;
        final isWeekExpanded = _expandedWeekGroups.contains(weekStart);
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Week header
            GroupHeader(
              title: _formatWeekTitle(weekStart),
              totalDuration: weekTotals[weekStart]!,
              timerCount: _countTimersInWeek(daysInWeek, dayGroups),
              isExpanded: isWeekExpanded,
              onToggleExpanded: () => _toggleWeekGroup(weekStart),
              headerType: GroupHeaderType.weekly,
            ),
            
            // Day groups within this week (only visible if week is expanded)
            AnimatedCrossFade(
              firstChild: Column(
                children: daysInWeek.map((dayKey) {
                  final dayGroup = dayGroups[dayKey]!;
                  final isDayExpanded = _expandedDayGroups.contains(dayKey);
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Day header
                      GroupHeader(
                        title: dayGroup.title,
                        totalDuration: dayGroup.totalDuration,
                        timerCount: dayGroup.count,
                        isExpanded: isDayExpanded,
                        onToggleExpanded: () => _toggleDayGroup(dayKey),
                        headerType: GroupHeaderType.daily,
                      ),
                      
                      // Timers in this day group (only visible if day is expanded)
                      AnimatedCrossFade(
                        firstChild: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: dayGroup.timers.map((timer) {
                              return TimerCard(
                                key: ValueKey(timer.id),
                                timer: timer,
                                isSelected: _selectedTimerIds.contains(timer.id),
                                currentTime: _currentTime,
                                onToggle: () => _toggleTimer(timer.id),
                                onSelect: () => _toggleTimerSelection(timer.id),
                                onDelete: () => _deleteTimer(timer.id),
                                onUpdate: _updateTimer,
                              );
                            }).toList(),
                          ),
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: isDayExpanded 
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  );
                }).toList(),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isWeekExpanded 
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
            
            // Add divider between weeks
            if (weekIndex < sortedWeekKeys.length - 1)
              const Divider(height: 24, thickness: 1),
          ],
        );
      },
    );
  }
  
  // Format a week title
  String _formatWeekTitle(DateTime weekStart) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = TimerGroupingUtil.getStartOfWeek(today);
    
    if (weekStart == thisWeekStart) {
      return 'This Week';
    } else if (weekStart == thisWeekStart.subtract(const Duration(days: 7))) {
      return 'Last Week';
    } else {
      final weekEnd = weekStart.add(const Duration(days: 6));
      final monthStart = _getMonthName(weekStart.month);
      final monthEnd = _getMonthName(weekEnd.month);
      
      if (weekStart.month == weekEnd.month) {
        return '$monthStart ${weekStart.day} - ${weekEnd.day}${_shouldIncludeYear(weekStart) ? ', ${weekStart.year}' : ''}';
      } else {
        return '$monthStart ${weekStart.day} - $monthEnd ${weekEnd.day}${_shouldIncludeYear(weekStart) ? ', ${weekStart.year}' : ''}';
      }
    }
  }
  
  // Gets the name of a month
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  // Determines if the year should be included in the date format
  bool _shouldIncludeYear(DateTime date) {
    final now = DateTime.now();
    return date.year != now.year;
  }
  
  // Count total timers in a week
  int _countTimersInWeek(List<DateTime> dayKeys, Map<DateTime, TimerGroup> dayGroups) {
    int count = 0;
    for (final dayKey in dayKeys) {
      count += dayGroups[dayKey]!.count;
    }
    return count;
  }
} 