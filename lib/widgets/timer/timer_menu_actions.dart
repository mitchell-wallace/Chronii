import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import '../base/base_menu_actions.dart';
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
    final menuItems = <PopupMenuItem<String>>[
      BaseMenuButton.createMenuItem(
        value: 'edit',
        icon: Icons.edit,
        text: 'Edit',
      ),
      BaseMenuButton.createMenuItem(
        value: 'delete',
        icon: Icons.delete,
        text: 'Delete',
      ),
    ];
    
    return BaseMenuButton(
      items: menuItems,
      onSelected: (value) {
        if (value == 'edit') {
          _editTimer(context);
        } else if (value == 'delete') {
          onDelete();
        }
      },
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