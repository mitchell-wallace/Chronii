import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/todo_model.dart';
import '../../utils/priority_utils.dart';
import '../base/base_item_card.dart';
import 'todo_menu_actions.dart';

/// A card widget for displaying a todo item
class TodoCard extends StatelessWidget {
  /// The todo item to display
  final Todo todo;
  
  /// Callback for when the todo completion status is toggled
  final VoidCallback onToggle;
  
  /// Callback for when the todo is deleted
  final VoidCallback onDelete;
  
  /// Callback for when the todo is updated
  final Function(Todo) onUpdate;
  
  /// Whether the todo is selected
  final bool isSelected;
  
  /// Callback for when selection state changes
  final VoidCallback onSelect;
  
  /// Callback for when the stopwatch button is pressed to create a timer from this todo
  final Function(String) onCreateTimer;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onUpdate,
    required this.onSelect,
    required this.isSelected,
    required this.onCreateTimer,
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
    
    // Get priority color
    final priorityColor = PriorityUtils.getPriorityColor(todo.priority);
    
    // Create truncated description (show first two lines only)
    final String? truncatedDescription = todo.description != null && todo.description!.isNotEmpty
        ? todo.description!.split('\n').take(2).join('\n')
        : null;
    
    // Create tags and due date subtitles
    final List<Widget> chips = [];
    
    // Add due date chip if present
    if (hasDueDate) {
      chips.add(Chip(
        label: Text(
          formattedDueDate!,
          style: TextStyle(
            fontSize: 12,
            color: isOverdue ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: isOverdue 
            ? Colors.red.withOpacity(0.7)
            : theme.colorScheme.surfaceVariant,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      ));
    }
    
    // Add up to 2 tags if present
    if (todo.tags.isNotEmpty) {
      final displayTags = todo.tags.take(2).toList();
      for (final tag in displayTags) {
        chips.add(Chip(
          label: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          backgroundColor: theme.colorScheme.surfaceVariant,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        ));
      }
      
      // Add count indicator if there are more tags
      if (todo.tags.length > 2) {
        chips.add(Chip(
          label: Text(
            '+${todo.tags.length - 2}',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          backgroundColor: theme.colorScheme.surfaceVariant,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        ));
      }
    }
    
    // Create checkbox for completion toggle
    final checkbox = Checkbox(
      value: todo.isCompleted,
      onChanged: (_) => onToggle(),
      activeColor: theme.colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
    
    // Create menu button for edit and delete
    final menuButton = TodoMenuButton(
      todo: todo, 
      onUpdate: onUpdate, 
      onDelete: onDelete
    );
    
    // Create selection indicator
    final selectionIndicator = Icon(
      isSelected ? Icons.check_circle : Icons.circle_outlined,
      color: isSelected ? theme.colorScheme.primary : theme.disabledColor,
    );
    
    // Create stopwatch button
    final stopwatchButton = IconButton(
      icon: const Icon(
        Icons.timer,
        color: Colors.blue,
        size: 22,
      ),
      onPressed: () => onCreateTimer(todo.title),
      tooltip: 'Create timer from this task',
    );
    
    // Wrap in a container with a priority color strip on the left
    return Stack(
      children: [
        // Priority color strip
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 4,
            color: priorityColor,
          ),
        ),
        
        // Base item card with padding to accommodate the priority strip
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: BaseItemCard(
            itemKey: Key(todo.id),
            title: todo.title,
            subtitle: truncatedDescription,
            additionalContent: chips.isEmpty ? null : Wrap(
              spacing: 4,
              runSpacing: 4,
              children: chips,
            ),
            isSelected: isSelected,
            isCompleted: todo.isCompleted,
            completedDecoration: TextDecoration.lineThrough,
            onTap: onSelect,
            onLongPress: onSelect,
            onDelete: onDelete,
            leading: checkbox,
            actions: [stopwatchButton, menuButton],
          ),
        ),
      ],
    );
  }
}
