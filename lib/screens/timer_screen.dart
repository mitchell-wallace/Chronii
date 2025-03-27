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
    await _timerService.init();
    setState(() {}); // Refresh UI after loading timers
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
    final timers = _timerService.timers;
    final totalDuration = _timerService.calculateTotalDuration(_selectedTimerIds.toList());
    
    return Column(
      children: [
        // New timer form
        TimerForm(onCreateTimer: _createTimer),
        
        // Timer list
        Expanded(
          child: timers.isEmpty
              ? _buildEmptyState(context)
              : _buildTimersList(timers),
        ),
        
        // Selected timers summary
        if (_selectedTimerIds.isNotEmpty)
          TimerSummary(
            selectedCount: _selectedTimerIds.length,
            totalDuration: totalDuration,
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 70,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No timers yet',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Create one to start tracking time!',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimersList(List<TaskTimer> timers) {
    return ListView.builder(
      itemCount: timers.length,
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