import 'package:flutter/material.dart';
import '../../models/todo_model.dart';

/// A card widget for displaying a todo item
class TodoCard extends StatelessWidget {
  /// The todo item to display
  final Todo todo;
  
  /// Callback for when the todo completion status is toggled
  final VoidCallback onToggle;
  
  /// Callback for when the todo is deleted
  final VoidCallback onDelete;
  
  /// Callback for when the card is tapped
  final VoidCallback? onTap;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      key: Key(todo.id),
      elevation: 2,
      child: InkWell(
        onTap: onTap ?? onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Checkbox
              Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Todo text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted 
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (todo.description != null && todo.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          todo.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Delete button
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete Task',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
