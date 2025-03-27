import 'package:flutter/material.dart';
import 'dart:async';
import '../models/timer_model.dart';
import '../services/timer_service.dart';
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

  // Delete timer
  Future<void> _deleteTimer(String timerId) async {
    await _timerService.deleteTimer(timerId);
    setState(() {
      _selectedTimerIds.remove(timerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timers = _timerService.timers;
    final totalDuration = _timerService.calculateTotalDuration(_selectedTimerIds.toList());
    
    return Padding(
      padding: const EdgeInsets.all(16.0), // Match padding with TodoListView
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
                    ? _buildEmptyState(theme)
                    : _buildTimersList(timers),
          ),
          
          // Selected timers summary
          if (_selectedTimerIds.isNotEmpty)
            TimerSummary(
              selectedCount: _selectedTimerIds.length,
              totalDuration: totalDuration,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No timers yet! Add one.',
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimersList(List<TaskTimer> timers) {
    return ListView.builder(
      itemCount: timers.length,
      padding: EdgeInsets.zero, // Remove padding to match TodoListView
      itemBuilder: (context, index) {
        // Show newest timers first
        final timer = timers[timers.length - 1 - index];
        
        return TimerCard(
          timer: timer,
          isSelected: _selectedTimerIds.contains(timer.id),
          currentTime: _currentTime,
          onToggle: () => _toggleTimer(timer.id),
          onSelect: () => _toggleTimerSelection(timer.id),
          onDelete: () => _deleteTimer(timer.id),
        );
      },
    );
  }
} 