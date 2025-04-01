import 'package:flutter/material.dart';
import '../../models/todo_model.dart';

/// A widget that displays a summary of selected todos and actions.
/// This appears at the bottom of the screen when one or more todos are selected.
class TodoSummary extends StatelessWidget {
  /// The number of selected todos.
  final int selectedCount;
  
  /// List of selected todos to calculate completion status
  final List<Todo> selectedTodos;
  
  /// Callback when the user wants to deselect all todos.
  final VoidCallback onDeselectAll;
  
  /// Callback when the user wants to delete all selected todos.
  final VoidCallback onDeleteAll;
  
  const TodoSummary({
    super.key,
    required this.selectedCount,
    required this.selectedTodos,
    required this.onDeselectAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate completed count
    final int completedCount = selectedTodos.where((todo) => todo.isCompleted).length;
    
    // Create the completion status widget
    final Widget completionStatus = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Completed',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '$completedCount/$selectedCount',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
    
    // Don't use BaseSummary - implement directly as a workaround
    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Selected count
                Text(
                  'Selected: $selectedCount ${selectedCount == 1 ? 'task' : 'tasks'}',
                  style: theme.textTheme.titleMedium,
                ),
                
                const Spacer(),
                
                // Right side content (completion status)
                completionStatus,
              ],
            ),
            
            // Action buttons
            if (selectedCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    // Deselect All button - direct implementation
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
      ),
    );
  }
}
