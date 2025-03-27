import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import '../../utils/time_formatter.dart';
import '../base/base_item_card.dart';

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
    
    // Create a duration display widget
    final durationWidget = Text(
      TimeFormatter.formatDuration(duration),
      style: theme.textTheme.titleLarge?.copyWith(
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      ),
    );
    
    // Create start/stop action button
    final actionButton = IconButton(
      icon: Icon(
        timer.isRunning ? Icons.stop_circle : Icons.play_circle,
        color: timer.isRunning ? Colors.red : Colors.green,
        size: 40,
      ),
      onPressed: onToggle,
    );
    
    // Selection indicator
    final selectionIndicator = Icon(
      isSelected ? Icons.check_circle : Icons.circle_outlined,
      color: isSelected ? theme.colorScheme.primary : theme.disabledColor,
    );
    
    // Use our base item card component
    return BaseItemCard(
      itemKey: Key(timer.id),
      title: timer.name,
      subtitle: _formatTimePeriod(timer, currentTime),
      isSelected: isSelected,
      isCompleted: !timer.isRunning, // A non-running timer is considered "completed"
      completedDecoration: null, // Don't use strikethrough for timers
      onTap: onSelect,
      onDelete: onDelete,
      leading: selectionIndicator,
      actions: [actionButton],
      additionalContent: durationWidget,
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