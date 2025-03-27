import 'package:flutter/material.dart';
import '../../utils/time_formatter.dart';
import 'timer_menu_actions.dart';

/// Widget for displaying summary of selected timers
class TimerSummary extends StatelessWidget {
  /// Number of selected timers
  final int selectedCount;
  
  /// Total duration of selected timers
  final Duration totalDuration;
  
  /// Callback to deselect all timers
  final VoidCallback onDeselectAll;
  
  /// Constructor
  const TimerSummary({
    super.key,
    required this.selectedCount,
    required this.totalDuration,
    required this.onDeselectAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Selected count
              Text(
                'Selected: $selectedCount ${selectedCount == 1 ? 'timer' : 'timers'}',
                style: theme.textTheme.titleMedium,
              ),
              
              const Spacer(),
              
              // Total time
              Column(
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
              ),
            ],
          ),
          
          // Deselect All button
          if (selectedCount > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: TimerDeselectAllButton(
                selectedCount: selectedCount,
                onDeselectAll: onDeselectAll,
              ),
            ),
        ],
      ),
    );
  }
} 