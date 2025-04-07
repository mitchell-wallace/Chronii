import 'package:flutter/material.dart';
import '../../models/todo_model.dart';
import '../base/base_input_form.dart';
import 'todo_create_dialog.dart';

/// Form component for adding/editing todo items
/// Extends the base input form with todo-specific logic
class TodoForm extends StatelessWidget {
  /// Callback for when a new todo is submitted with just a title
  final Function(String text) onSubmit;
  
  /// Callback for when a detailed todo is created
  final Function(String title, {String? description, DateTime? dueDate, TodoPriority priority, List<String>? tags})? onCreateDetailed;
  
  /// Whether to autofocus the input field
  final bool autoFocus;
  
  /// Whether to show a border around the input
  final bool showBorder;
  
  /// Text to display on the submit button
  final String buttonText;
  
  /// Icon to display on the submit button
  final IconData buttonIcon;

  const TodoForm({
    super.key,
    required this.onSubmit,
    this.onCreateDetailed,
    this.autoFocus = false,
    this.showBorder = false,
    this.buttonText = 'Add',
    this.buttonIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return BaseInputForm(
      hintText: 'Add a new task',
      buttonText: buttonText,
      buttonIcon: buttonIcon,
      autoFocus: autoFocus,
      showBorder: showBorder,
      onSubmit: onSubmit,
    );
  }
  
  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => TodoCreateDialog(
        onCreateTodo: (title, {description, dueDate, priority, tags}) {
          if (onCreateDetailed != null) {
            onCreateDetailed!(
              title,
              description: description,
              dueDate: dueDate,
              priority: priority ?? TodoPriority.medium,
              tags: tags,
            );
          } else {
            // Fallback to simple title-only creation
            onSubmit(title);
          }
        },
      ),
    );
  }
}
