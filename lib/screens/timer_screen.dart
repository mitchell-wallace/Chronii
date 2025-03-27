import 'package:flutter/material.dart';
import 'dart:async';
import '../models/timer_model.dart';
import '../services/timer_service.dart';
import '../widgets/base/base_empty_state.dart';
import '../widgets/timer/timer_card.dart';
import '../widgets/timer/timer_form.dart';
import '../widgets/timer/timer_summary.dart';

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

  // Build the list of timers
  Widget _buildTimersList(List<TaskTimer> timers) {
    // Sort timers by start time, most recent first
    final sortedTimers = List<TaskTimer>.from(timers);
    sortedTimers.sort((a, b) => b.startTime.compareTo(a.startTime));
    
    return ListView.builder(
      itemCount: sortedTimers.length,
      padding: EdgeInsets.zero, // No padding to match TodoListView
      itemBuilder: (context, index) {
        final timer = sortedTimers[index];
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timers = _timerService.timers;
    final totalDuration = _timerService.calculateTotalDuration(_selectedTimerIds.toList());
    
    // Main content with padding on top, left, and right only
    Widget mainContent = Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: Column(
        children: [
          // New timer form
          TimerForm(onCreateTimer: _createTimer),
          
          const SizedBox(height: 16), // Consistent spacing
          
          // Timer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : timers.isEmpty
                    ? const BaseEmptyState(
                        icon: Icons.timer_outlined,
                        message: 'No timers yet',
                        subMessage: 'Create a timer to get started',
                      )
                    : _buildTimersList(timers),
          ),
        ],
      ),
    );
    
    return Column(
      children: [
        // Main content (with padding)
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
} 