import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  // Timer model list
  final List<TaskTimer> _timers = [];
  // Selected timer IDs
  final Set<String> _selectedTimerIds = {};
  // Controller for new timer name input
  final TextEditingController _timerNameController = TextEditingController();
  // Timer for updating UI every second
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    // Load saved timers
    _loadTimers();
    
    // Start a timer to update the UI every second
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // This will trigger a rebuild to update the displayed durations
        });
      }
    });
  }

  @override
  void dispose() {
    _uiUpdateTimer?.cancel();
    _timerNameController.dispose();
    super.dispose();
  }

  // Load timers from SharedPreferences
  Future<void> _loadTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = prefs.getString('timers');
      
      if (timersJson != null) {
        final List<dynamic> decoded = jsonDecode(timersJson);
        setState(() {
          _timers.clear();
          _timers.addAll(decoded.map((timerMap) => TaskTimer.fromJson(timerMap)));
        });
      }
    } catch (e) {
      debugPrint('Error loading timers: $e');
    }
  }

  // Save timers to SharedPreferences
  Future<void> _saveTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = jsonEncode(_timers.map((timer) => timer.toJson()).toList());
      await prefs.setString('timers', timersJson);
    } catch (e) {
      debugPrint('Error saving timers: $e');
    }
  }

  // Calculate total duration of selected timers
  Duration get _totalSelectedDuration {
    final now = DateTime.now();
    return _timers
        .where((timer) => _selectedTimerIds.contains(timer.id))
        .fold(Duration.zero, (previous, timer) {
      return previous + timer.getDuration(now);
    });
  }

  // Create a new timer
  void _createTimer(String name) {
    if (name.trim().isEmpty) return;
    
    setState(() {
      _timers.add(TaskTimer(
        name: name.trim(),
        startTime: DateTime.now(),
      ));
    });
    _timerNameController.clear();
    _saveTimers();
  }

  // Toggle timer running state
  void _toggleTimer(TaskTimer timer) {
    setState(() {
      if (timer.isRunning) {
        // Stop the timer
        timer.endTime = DateTime.now();
      } else {
        // Create a new timer with the same name
        _timers.add(TaskTimer(
          name: timer.name,
          startTime: DateTime.now(),
        ));
      }
    });
    _saveTimers();
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
  void _deleteTimer(String timerId) {
    setState(() {
      _timers.removeWhere((timer) => timer.id == timerId);
      _selectedTimerIds.remove(timerId);
    });
    _saveTimers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Timers'),
      ),
      body: Column(
        children: [
          // New timer input form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Task Name',
                      hintText: 'Enter task name',
                    ),
                    onSubmitted: (value) => _createTimer(value),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _createTimer(_timerNameController.text),
                  child: const Text('Start Timer'),
                ),
              ],
            ),
          ),
          
          // Timer list
          Expanded(
            child: _timers.isEmpty
                ? Center(
                    child: Text(
                      'No timers yet. Create one to start tracking time!',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _timers.length,
                    itemBuilder: (context, index) {
                      final timer = _timers[_timers.length - 1 - index]; // Show newest first
                      final now = DateTime.now();
                      
                      return TimerCard(
                        timer: timer, 
                        isSelected: _selectedTimerIds.contains(timer.id),
                        onToggle: () => _toggleTimer(timer),
                        onSelect: () => _toggleTimerSelection(timer.id),
                        onDelete: () => _deleteTimer(timer.id),
                        currentTime: now,
                      );
                    },
                  ),
          ),
          
          // Selected timers summary
          if (_selectedTimerIds.isNotEmpty)
            Container(
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Selected: ${_selectedTimerIds.length} ${_selectedTimerIds.length == 1 ? 'timer' : 'timers'}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  Text(
                    'Total: ${_formatDuration(_totalSelectedDuration)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}

// Timer card widget to display a single timer
class TimerCard extends StatelessWidget {
  final TaskTimer timer;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final DateTime currentTime;

  const TimerCard({
    super.key,
    required this.timer,
    required this.isSelected,
    required this.onToggle,
    required this.onSelect,
    required this.onDelete,
    required this.currentTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final duration = timer.getDuration(currentTime);
    
    return Dismissible(
      key: Key(timer.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.3) : null,
        child: InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Selection indicator
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? theme.colorScheme.primary : theme.disabledColor,
                ),
                
                const SizedBox(width: 16),
                
                // Timer info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timer.name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimePeriod(timer, currentTime),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDuration(duration),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Start/stop button
                IconButton(
                  icon: Icon(
                    timer.isRunning ? Icons.stop_circle : Icons.play_circle,
                    color: timer.isRunning ? Colors.red : Colors.green,
                    size: 40,
                  ),
                  onPressed: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Format time period display
  String _formatTimePeriod(TaskTimer timer, DateTime currentTime) {
    final startTime = _formatDateTime(timer.startTime);
    if (timer.isRunning) {
      return 'Started: $startTime';
    } else {
      final endTime = _formatDateTime(timer.endTime!);
      return 'Period: $startTime - $endTime';
    }
  }

  // Format date time for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  // Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }
}

// Timer model
class TaskTimer {
  final String id;
  final String name;
  final DateTime startTime;
  DateTime? endTime;

  TaskTimer({
    required this.name,
    required this.startTime,
    this.endTime,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Check if timer is running
  bool get isRunning => endTime == null;

  // Get current duration
  Duration getDuration(DateTime currentTime) {
    final end = endTime ?? currentTime;
    return end.difference(startTime);
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
  };

  // Create from JSON
  factory TaskTimer.fromJson(Map<String, dynamic> json) => TaskTimer(
    id: json['id'],
    name: json['name'],
    startTime: DateTime.parse(json['startTime']),
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
  );
} 