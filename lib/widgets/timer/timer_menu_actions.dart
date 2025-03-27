import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import 'timer_edit_modal.dart';

/// A button to show the timer options menu (three vertical dots)
class TimerMenuButton extends StatelessWidget {
  /// The timer associated with this menu
  final TaskTimer timer;

  /// Callback when the timer is updated
  final Function(TaskTimer) onUpdate;

  /// Callback when the timer is deleted
  final VoidCallback onDelete;

  /// Constructor
  const TimerMenuButton({
    super.key,
    required this.timer,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'edit') {
          _editTimer(context);
        } else if (value == 'delete') {
          onDelete();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 20),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }

  void _editTimer(BuildContext context) {
    TimerEditModal.show(context, timer, onUpdate);
  }
}

/// A button to deselect all timers
class TimerDeselectAllButton extends StatelessWidget {
  /// Callback when deselect all is pressed
  final VoidCallback onDeselectAll;
  
  /// Number of selected timers
  final int selectedCount;

  /// Constructor
  const TimerDeselectAllButton({
    super.key,
    required this.onDeselectAll,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink(); // Don't show if nothing is selected
    }
    
    final theme = Theme.of(context);
    
    return TextButton.icon(
      onPressed: onDeselectAll,
      icon: const Icon(Icons.clear_all, size: 20),
      label: const Text('Deselect All'),
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
} 