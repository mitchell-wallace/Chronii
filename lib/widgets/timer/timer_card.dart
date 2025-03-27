import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import '../../utils/time_formatter.dart';

/// A card widget representing a single task timer
class TimerCard extends StatelessWidget {
  /// The timer model to display
  final TaskTimer timer;
  
  /// Whether this timer is selected
  final bool isSelected;
  
  /// Current time for calculating elapsed duration
  final DateTime currentTime;
  
  /// Callback when the timer's start/stop button is pressed
  final VoidCallback onToggle;
  
  /// Callback when the card is tapped (for selection)
  final VoidCallback onSelect;
  
  /// Callback when the timer is deleted
  final VoidCallback onDelete;

  /// Constructor
  const TimerCard({
    super.key,
    required this.timer,
    required this.isSelected,
    required this.currentTime,
    required this.onToggle,
    required this.onSelect,
    required this.onDelete,
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
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3) 
            : null,
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
                        TimeFormatter.formatDuration(duration),
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

  /// Format time period display
  String _formatTimePeriod(TaskTimer timer, DateTime currentTime) {
    final startTime = TimeFormatter.formatDateTime(timer.startTime);
    if (timer.isRunning) {
      return 'Started: $startTime';
    } else {
      final endTime = TimeFormatter.formatDateTime(timer.endTime!);
      return 'Period: $startTime - $endTime';
    }
  }
} 