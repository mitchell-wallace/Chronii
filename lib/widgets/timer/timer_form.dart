import 'package:flutter/material.dart';
import '../base/base_input_form.dart';

/// Widget for creating new timers
class TimerForm extends StatelessWidget {
  /// Callback when a new timer is created
  final void Function(String name) onCreateTimer;

  /// Constructor
  const TimerForm({super.key, required this.onCreateTimer});

  @override
  Widget build(BuildContext context) {
    return BaseInputForm(
      hintText: 'Add a new timer',
      buttonText: 'Start',
      buttonIcon: Icons.play_arrow,
      showBorder: false,
      autoFocus: false,
      onSubmit: onCreateTimer,
    );
  }
} 