import 'package:flutter/material.dart';

/// A widget that displays a summary of selected todos and actions.
/// This appears at the bottom of the screen when one or more todos are selected.
class TodoSummary extends StatelessWidget {
  /// The number of selected todos.
  final int selectedCount;
  
  /// Callback when the user wants to deselect all todos.
  final VoidCallback onDeselectAll;
  
  /// Callback when the user wants to delete all selected todos.
  final VoidCallback onDeleteAll;
  
  const TodoSummary({
    super.key,
    required this.selectedCount,
    required this.onDeselectAll,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Text(
              '$selectedCount ${selectedCount == 1 ? 'task' : 'tasks'} selected',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onDeselectAll,
              child: const Text('Deselect All'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onDeleteAll,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}
