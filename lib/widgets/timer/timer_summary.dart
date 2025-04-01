import 'package:flutter/material.dart';
import '../../utils/time_formatter.dart';
import '../base/base_summary.dart';

/// Widget for displaying summary of selected timers
class TimerSummary extends StatelessWidget {
  /// Number of selected timers
  final int selectedCount;
  
  /// Total duration of selected timers
  final Duration totalDuration;
  
  /// Callback to deselect all timers
  final VoidCallback onDeselectAll;
  
  /// Callback to delete all selected timers
  final VoidCallback onDeleteAll;
  
  /// Constructor
  const TimerSummary({
    super.key,
    required this.selectedCount,
    required this.totalDuration,
    required this.onDeselectAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Create a widget to display total duration
    final Widget timeWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total Time',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          TimeFormatter.formatDuration(totalDuration),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    
    return BaseSummary(
      selectedCount: selectedCount,
      itemType: 'timer',
      rightSideContent: timeWidget,
      onDeselectAll: onDeselectAll,
      onDeleteAll: onDeleteAll,
    );
  }
}