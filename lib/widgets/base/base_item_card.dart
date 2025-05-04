import 'package:flutter/material.dart';

/// A reusable base item card component that can be customized for different types of items
/// This can be used for todo items, timer cards, or any other item display in the app
class BaseItemCard extends StatelessWidget {
  /// Unique key for the item
  final Key itemKey;
  
  /// The title of the item
  final String title;
  
  /// Optional subtitle or description
  final String? subtitle;
  
  /// Whether the item is selected
  final bool isSelected;
  
  /// Whether the item is marked as completed/finished
  final bool isCompleted;
  
  /// Leading widget to display (e.g., checkbox, icon)
  final Widget? leading;
  
  /// Action buttons to display at the end
  final List<Widget>? actions;
  
  /// Callback when the item is tapped
  final VoidCallback? onTap;
  
  /// Callback when the item is long-pressed
  final VoidCallback? onLongPress;
  
  /// Callback when the item is deleted
  final VoidCallback? onDelete;
  
  /// Additional content to display below the title and subtitle
  final Widget? additionalContent;
  
  /// Color to use for the card
  /// If null, it will use the default card color or the theme's surface color
  final Color? cardColor;
  
  /// Optional decoration for the completed state
  final TextDecoration? completedDecoration;
  
  /// Optional badge to display (e.g., for showing counts or status)
  final Widget? badge;
  
  /// Constructor
  const BaseItemCard({
    super.key,
    required this.itemKey,
    required this.title,
    this.subtitle,
    this.isSelected = false,
    this.isCompleted = false,
    this.leading,
    this.actions,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.additionalContent,
    this.cardColor,
    this.completedDecoration = TextDecoration.lineThrough,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine the background color based on selection and completion state
    final backgroundColor = cardColor ?? 
        (isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : (isCompleted 
                ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                : theme.colorScheme.surface));
    
    // Determine the text color based on completion state
    final textColor = isCompleted
        ? theme.colorScheme.onSurface.withOpacity(0.6)
        : theme.colorScheme.onSurface;
    
    return Dismissible(
      key: itemKey,
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: onDelete != null ? (_) => onDelete!() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading widget (like checkbox)
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 16),
                  ],
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Title
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  decoration: isCompleted ? completedDecoration : null,
                                  fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            
                            // Badge if any
                            if (badge != null) badge!,
                          ],
                        ),
                        
                        // Subtitle if any
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                        
                        // Additional content if any
                        if (additionalContent != null) ...[
                          const SizedBox(height: 8),
                          additionalContent!,
                        ],
                      ],
                    ),
                  ),
                  
                  // Actions
                  if (actions != null && actions!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ...actions!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 