import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
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
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        if (value == 'edit') {
          _editTodo(context);
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

  void _editTodo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TodoEditDialog(
        todo: todo,
        onUpdate: (updatedTodo) {
          Navigator.of(context).pop();
          onUpdate(updatedTodo);
        },
      ),
    );
  }
}
