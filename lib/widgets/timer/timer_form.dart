import 'package:flutter/material.dart';

/// Widget for creating new timers
class TimerForm extends StatefulWidget {
  /// Callback when a new timer is created
  final void Function(String name) onCreateTimer;

  /// Constructor
  const TimerForm({super.key, required this.onCreateTimer});

  @override
  State<TimerForm> createState() => _TimerFormState();
}

class _TimerFormState extends State<TimerForm> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onCreateTimer(name);
      _nameController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                hintText: 'Enter task name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.go,
              onSubmitted: (_) => _submitForm(),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 56, // Match height with TextField
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow),
                  SizedBox(width: 8),
                  Text('Start Timer'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 