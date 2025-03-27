import 'package:flutter/material.dart';
import '../../models/timer_model.dart';
import 'package:intl/intl.dart';

/// A modal dialog for editing timer details including name, start time, and end time
class TimerEditModal extends StatefulWidget {
  /// The timer to edit
  final TaskTimer timer;

  /// Callback when the timer is updated
  final Function(TaskTimer) onUpdate;

  /// Constructor
  const TimerEditModal({
    super.key,
    required this.timer,
    required this.onUpdate,
  });

  /// Shows the modal dialog
  static Future<void> show(
    BuildContext context, 
    TaskTimer timer, 
    Function(TaskTimer) onUpdate
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TimerEditModal(
          timer: timer,
          onUpdate: onUpdate,
        );
      },
    );
  }

  @override
  State<TimerEditModal> createState() => _TimerEditModalState();
}

class _TimerEditModalState extends State<TimerEditModal> {
  late TextEditingController _nameController;
  late DateTime _startTime;
  late DateTime _endTime;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.timer.name);
    _startTime = widget.timer.startTime;
    _endTime = widget.timer.endTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Validate
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Timer name cannot be empty';
      });
      return;
    }

    if (_endTime.isBefore(_startTime)) {
      setState(() {
        _errorMessage = 'End time must be after start time';
      });
      return;
    }

    // Create updated timer
    final updatedTimer = TaskTimer(
      id: widget.timer.id,
      name: _nameController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
    );

    widget.onUpdate(updatedTimer);
    Navigator.of(context).pop();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    DateTime initialDate = isStartTime ? _startTime : _endTime;
    
    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate == null) return;
    
    // Show time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );
    
    if (pickedTime == null) return;
    
    // Combine date and time
    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    
    setState(() {
      if (isStartTime) {
        _startTime = newDateTime;
        // If end time is before new start time, adjust it
        if (_endTime.isBefore(_startTime)) {
          _endTime = _startTime.add(const Duration(hours: 1));
        }
      } else {
        _endTime = newDateTime;
      }
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('Edit Timer', style: theme.textTheme.titleLarge),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Timer name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Timer Name',
                hintText: 'Enter a name for this timer',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            
            // Start time
            _DateTimePicker(
              label: 'Start Time',
              dateTime: _startTime,
              onPressed: () => _selectDateTime(true),
            ),
            const SizedBox(height: 16),
            
            // End time
            _DateTimePicker(
              label: 'End Time',
              dateTime: _endTime,
              onPressed: () => _selectDateTime(false),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveChanges,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// A widget for displaying and selecting date/time
class _DateTimePicker extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final VoidCallback onPressed;

  const _DateTimePicker({
    required this.label,
    required this.dateTime,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateFormat.format(dateTime),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(dateTime),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 