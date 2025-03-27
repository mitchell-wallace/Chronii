import 'package:flutter/material.dart';
import '../../utils/time_formatter.dart';

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
          
          // Action buttons
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  // Deselect All button
                  TextButton.icon(
                    onPressed: onDeselectAll,
                    icon: const Icon(Icons.clear_all, size: 20),
                    label: const Text('Deselect All'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Delete All button
                  TextButton.icon(
                    onPressed: onDeleteAll,
                    icon: const Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    label: const Text('Delete All', style: TextStyle(color: Colors.red)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 