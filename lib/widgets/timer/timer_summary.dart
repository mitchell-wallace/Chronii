import 'package:flutter/material.dart';
import '../../utils/time_formatter.dart';

/// Widget for displaying summary of selected timers
class TimerSummary extends StatelessWidget {
  /// Number of selected timers
  final int selectedCount;
  
  /// Total duration of selected timers
  final Duration totalDuration;
  
  /// Constructor
  const TimerSummary({
    super.key,
    required this.selectedCount,
    required this.totalDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
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
    );
  }
} 