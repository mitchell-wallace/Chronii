import 'package:flutter/material.dart';
import '../base/base_input_form.dart';

/// Form component for adding/editing todo items
/// Extends the base input form with todo-specific logic
class TodoForm extends StatelessWidget {
  /// Callback for when a new todo is submitted
  final Function(String text) onSubmit;
  
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
}
