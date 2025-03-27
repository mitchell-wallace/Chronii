import 'package:flutter/material.dart';

/// A reusable base input form component that can be customized for different types of inputs
/// This can be used for todo forms, timer forms, or any other input form in the app
class BaseInputForm extends StatefulWidget {
  /// The hint text to display in the input field
  final String hintText;
  
  /// The label text to display above the input field
  final String? labelText;
  
  /// The text to display on the submit button
  final String buttonText;
  
  /// The icon to display on the submit button
  final IconData? buttonIcon;
  
  /// Callback when the form is submitted with the input text
  final void Function(String text) onSubmit;
  
  /// Optional placeholder text for the input field
  final String? placeholderText;
  
  /// Whether the input field should have a border
  final bool showBorder;
  
  /// Optional help text to display below the input
  final String? helpText;
  
  /// Whether to auto-focus the input field
  final bool autoFocus;
  
  /// Optional callback for validating the input text
  final String? Function(String?)? validator;

  /// Constructor
  const BaseInputForm({
    super.key,
    required this.hintText,
    required this.buttonText,
    required this.onSubmit,
    this.labelText,
    this.buttonIcon,
    this.placeholderText,
    this.showBorder = false,
    this.helpText,
    this.autoFocus = false,
    this.validator,
  });

  @override
  State<BaseInputForm> createState() => _BaseInputFormState();
}

class _BaseInputFormState extends State<BaseInputForm> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    
    if (widget.autoFocus) {
      // Use a post-frame callback to focus the field after the build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  void _submitForm() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    // If validator is provided, check validation
    if (widget.validator != null) {
      final errorMessage = widget.validator!(text);
      if (errorMessage != null) {
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red)
        );
        return;
      }
    }
    
    widget.onSubmit(text);
    _textController.clear();
    
    // Keep focus on the input field after submitting
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.labelText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
                child: Text(
                  widget.labelText!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: widget.showBorder ? null : InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _submitForm(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.buttonIcon != null) ...[
                          Icon(widget.buttonIcon, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Text(widget.buttonText),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            
            if (widget.helpText != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                child: Text(
                  widget.helpText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 