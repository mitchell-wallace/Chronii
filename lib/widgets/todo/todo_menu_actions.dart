import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../base/base_menu_actions.dart';
import 'todo_edit_dialog.dart';

/// A button to show the todo options menu (three vertical dots)
class TodoMenuButton extends StatelessWidget {
  /// The todo associated with this menu
  final Todo todo;

  /// Callback when the todo is updated
  final Function(Todo) onUpdate;

  /// Callback when the todo is deleted
  final VoidCallback onDelete;

  /// Constructor
  const TodoMenuButton({
    super.key,
    required this.todo,
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
          _editTodo(context);
        } else if (value == 'delete') {
          onDelete();
        }
      },
    );
  }

  void _editTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TodoEditDialog(
        todo: todo,
        onUpdate: (updatedTodo) {
          onUpdate(updatedTodo);
        },
      ),
    );
  }
}
