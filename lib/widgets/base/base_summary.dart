import 'package:flutter/material.dart';

/// Base widget for displaying selection summaries
/// Used by both TimerSummary and TodoSummary to provide consistent UI
class BaseSummary extends StatelessWidget {
  /// Number of selected items
  final int selectedCount;
  
  /// Text to show in the item count (e.g., 'timers' or 'tasks')
  final String itemType;
  
  /// Widget to display on the right side (e.g., time summary or completion status)
  final Widget? rightSideContent;
  
  /// Callback to deselect all items
  final VoidCallback onDeselectAll;
  
  /// Callback to delete all selected items
  final VoidCallback onDeleteAll;
  
  /// Constructor
  const BaseSummary({
    super.key,
    required this.selectedCount,
    required this.itemType,
    this.rightSideContent,
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
                'Selected: $selectedCount ${selectedCount == 1 ? itemType : '${itemType}s'}',
                style: theme.textTheme.titleMedium,
              ),
              
              const Spacer(),
              
              // Right side content (e.g. time summary or completion status)
              if (rightSideContent != null) rightSideContent!,
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
                    onPressed: () {
                      print("Deselect All button pressed in BaseSummary");
                      onDeselectAll();
                    },
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
