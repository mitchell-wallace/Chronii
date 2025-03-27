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
  DateTime? _endTime;
  String? _errorMessage;
  bool _hasEndTime = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.timer.name);
    _startTime = widget.timer.startTime;
    _endTime = widget.timer.endTime;
    _hasEndTime = _endTime != null;
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

    if (_hasEndTime && _endTime != null && _endTime!.isBefore(_startTime)) {
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
      endTime: _hasEndTime ? _endTime : null,
    );

    widget.onUpdate(updatedTimer);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate(bool isStartTime) async {
    final DateTime initialDate = isStartTime ? _startTime : (_endTime ?? DateTime.now());
    
    // Show date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    
    if (pickedDate == null) return;
    
    setState(() {
      if (isStartTime) {
        // Keep the time portion of the current start time
        _startTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _startTime.hour,
          _startTime.minute,
        );
        
        // If end time exists and is now before start time, adjust it
        if (_hasEndTime && _endTime != null && _endTime!.isBefore(_startTime)) {
          _endTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            _endTime!.hour > _startTime.hour ? _endTime!.hour : _startTime.hour + 1,
            _endTime!.minute,
          );
        }
      } else if (_hasEndTime) {
        // Keep the time portion of the current end time
        final currentEndTime = _endTime ?? DateTime.now();
        _endTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          currentEndTime.hour,
          currentEndTime.minute,
        );
        
        // If end time is now before start time, adjust the time
        if (_endTime!.isBefore(_startTime)) {
          if (pickedDate.year == _startTime.year && 
              pickedDate.month == _startTime.month && 
              pickedDate.day == _startTime.day) {
            // Same day, set time to 1 hour after start
            _endTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              _startTime.hour + 1,
              _startTime.minute,
            );
          }
        }
      }
      _errorMessage = null;
    });
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay initialTime = TimeOfDay.fromDateTime(
      isStartTime ? _startTime : (_endTime ?? DateTime.now())
    );
    
    // Show time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    
    if (pickedTime == null) return;
    
    setState(() {
      if (isStartTime) {
        // Keep the date portion but update the time
        _startTime = DateTime(
          _startTime.year,
          _startTime.month,
          _startTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // If end time exists and is on the same day but now before start time, adjust it
        if (_hasEndTime && _endTime != null && _endTime!.day == _startTime.day && 
            _endTime!.month == _startTime.month && _endTime!.year == _startTime.year &&
            (_endTime!.hour < pickedTime.hour || 
             (_endTime!.hour == pickedTime.hour && _endTime!.minute <= pickedTime.minute))) {
          _endTime = DateTime(
            _endTime!.year,
            _endTime!.month,
            _endTime!.day,
            pickedTime.hour + 1,
            pickedTime.minute,
          );
        }
      } else if (_hasEndTime) {
        // Keep the date portion but update the time
        final DateTime currentEndTime = _endTime ?? DateTime.now();
        _endTime = DateTime(
          currentEndTime.year,
          currentEndTime.month,
          currentEndTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // If end time is on the same day as start time but now before it, adjust it
        if (_endTime!.day == _startTime.day && _endTime!.month == _startTime.month && 
            _endTime!.year == _startTime.year && _endTime!.isBefore(_startTime)) {
          // Set to same day but 1 hour after start
          _endTime = DateTime(
            _startTime.year,
            _startTime.month,
            _startTime.day,
            _startTime.hour + 1,
            _startTime.minute,
          );
        }
      }
      _errorMessage = null;
    });
  }

  void _toggleEndTime(bool value) {
    setState(() {
      _hasEndTime = value;
      if (value && _endTime == null) {
        // If enabling and no end time, set default to 1 hour after start
        _endTime = _startTime.add(const Duration(hours: 1));
      }
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
            Text(
              'Start Time',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Date picker
                Expanded(
                  child: _DateDisplay(
                    label: 'Date',
                    date: _startTime,
                    onPressed: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                // Time picker
                Expanded(
                  child: _TimeDisplay(
                    label: 'Time',
                    time: TimeOfDay.fromDateTime(_startTime),
                    onPressed: () => _selectTime(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // End time toggle
            Row(
              children: [
                Text(
                  'End Time',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _hasEndTime,
                  onChanged: _toggleEndTime,
                ),
              ],
            ),
            
            // End time pickers (only if enabled)
            if (_hasEndTime) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  // Date picker
                  Expanded(
                    child: _DateDisplay(
                      label: 'Date',
                      date: _endTime ?? DateTime.now(),
                      onPressed: () => _selectDate(false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time picker
                  Expanded(
                    child: _TimeDisplay(
                      label: 'Time',
                      time: TimeOfDay.fromDateTime(_endTime ?? DateTime.now()),
                      onPressed: () => _selectTime(false),
                    ),
                  ),
                ],
              ),
            ],
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

/// A widget for displaying and selecting a date
class _DateDisplay extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onPressed;

  const _DateDisplay({
    required this.label,
    required this.date,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(date),
                  style: theme.textTheme.bodyMedium,
                ),
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget for displaying and selecting a time
class _TimeDisplay extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onPressed;

  const _TimeDisplay({
    required this.label,
    required this.time,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Format time
    final formattedTime = _formatTimeOfDay(time, context);
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedTime,
                  style: theme.textTheme.bodyMedium,
                ),
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimeOfDay(TimeOfDay timeOfDay, BuildContext context) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat('hh:mm a').format(dateTime);
  }
} 