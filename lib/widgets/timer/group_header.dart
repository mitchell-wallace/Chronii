import 'package:flutter/material.dart';
import '../../utils/time_formatter.dart';

/// Header type enum
enum GroupHeaderType {
  /// Weekly header (primary)
  weekly,
  
  /// Daily header (secondary)
  daily,
}

/// Widget for displaying a header for a group of timers
class GroupHeader extends StatelessWidget {
  /// The title of the group
  final String title;
  
  /// The total duration of all timers in the group
  final Duration totalDuration;
  
  /// The number of timers in the group
  final int timerCount;
  
  /// Whether the group is expanded
  final bool isExpanded;
  
  /// Callback when the expand/collapse button is tapped
  final VoidCallback onToggleExpanded;
  
  /// The type of header (weekly or daily)
  final GroupHeaderType headerType;
  
  /// Constructor
  const GroupHeader({
    super.key,
    required this.title,
    required this.totalDuration,
    required this.timerCount,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.headerType = GroupHeaderType.weekly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Configure colors based on header type
    final Color backgroundColor = headerType == GroupHeaderType.weekly
        ? colorScheme.primaryContainer
        : colorScheme.secondaryContainer.withOpacity(0.7);
    
    // For daily headers, use the same color for all text elements
    final Color textColor = headerType == GroupHeaderType.weekly
        ? colorScheme.onPrimaryContainer
        : colorScheme.secondary;
    
    final Color durationColor = headerType == GroupHeaderType.weekly
        ? colorScheme.primary
        : colorScheme.secondary;
    
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onToggleExpanded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left section: Expand icon + title + count
              Expanded(
                child: Row(
                  children: [
                    // Expand/collapse icon
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: textColor,
                      size: 18,
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Group title and count
                    Text(
                      '$title • $timerCount ${timerCount == 1 ? 'timer' : 'timers'}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Right section: Total duration
              Text(
                '${TimeFormatter.formatDuration(totalDuration)} Total',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: durationColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 