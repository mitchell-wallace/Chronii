import 'package:flutter/material.dart';

/// A reusable empty state component that can be used across the app
class BaseEmptyState extends StatelessWidget {
  /// The icon to display
  final IconData icon;
  
  /// The primary message to display
  final String message;
  
  /// An optional secondary message with more details
  final String? subMessage;
  
  /// Color to use for the icon (defaults to theme's outline color)
  final Color? iconColor;
  
  /// Size of the icon
  final double iconSize;

  /// Constructor
  const BaseEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.iconColor,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Use a consistent color across the app
    final standardIconColor = theme.colorScheme.outline.withOpacity(0.7);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? standardIconColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (subMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              subMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
} 