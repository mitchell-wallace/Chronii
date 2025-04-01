import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/todo_model.dart';
import '../../utils/priority_utils.dart';
import 'todo_edit_dialog.dart';

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
  
  /// Callback for when the todo is updated
  final Function(Todo) onUpdate;
  
  /// Whether the todo is selected
  final bool isSelected;
  
  /// Callback for when selection state changes
  final VoidCallback? onSelect;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdate,
    this.onTap,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDueDate = todo.dueDate != null;
    final isOverdue = hasDueDate && todo.dueDate!.isBefore(DateTime.now()) && !todo.isCompleted;
    
    // Format due date if present
    final String? formattedDueDate = todo.dueDate != null 
        ? DateFormat('MMM d, yyyy').format(todo.dueDate!)
        : null;
    
    // Get priority color and icon
    final priorityColor = PriorityUtils.getPriorityColor(todo.priority);
    final priorityIcon = PriorityUtils.getPriorityIcon(todo.priority);
    
    // Create truncated description (show first two lines only)
    final String? truncatedDescription = todo.description != null && todo.description!.isNotEmpty
        ? todo.description!.split('\n').take(2).join('\n')
        : null;
    
    // Check if description is truncated
    final bool isDescriptionTruncated = todo.description != null && 
        todo.description!.split('\n').length > 2;
    
    return Card(
      key: Key(todo.id),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _showEditDialog(context),
        onLongPress: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
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
                  
                  // Todo title
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted 
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Selection indicator
                  if (onSelect != null)
                    IconButton(
                      icon: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: onSelect,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // Edit button
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditDialog(context),
                    tooltip: 'Edit Task',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Delete Task',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              // Description
              if (truncatedDescription != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 36),
                  child: Text(
                    truncatedDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              if (isDescriptionTruncated)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 36),
                  child: Text(
                    '...',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              
              // Due date and tags
              if (hasDueDate || todo.tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 36),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      // Due date chip
                      if (hasDueDate)
                        Chip(
                          label: Text(
                            formattedDueDate!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isOverdue 
                                  ? Colors.white 
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          backgroundColor: isOverdue 
                              ? Colors.red 
                              : theme.colorScheme.surfaceVariant,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: isOverdue 
                                ? Colors.white 
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      
                      // Tag chips (show up to 2 tags)
                      ...todo.tags.take(2).map((tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      )),
                      
                      // Show count of remaining tags if any
                      if (todo.tags.length > 2)
                        Chip(
                          label: Text(
                            '+${todo.tags.length - 2}',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TodoEditDialog(
        todo: todo,
        onUpdate: onUpdate,
      ),
    );
  }
}
