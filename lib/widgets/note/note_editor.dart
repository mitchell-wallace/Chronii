import 'package:flutter/material.dart';
import '../../models/note_model.dart';

/// Widget for editing a note
class NoteEditor extends StatefulWidget {
  /// The note to edit
  final Note note;
  
  /// Callback for when note is updated
  final Function(Note) onNoteUpdate;
  
  /// Callback for when note is deleted
  final Function(String) onNoteDelete;

  const NoteEditor({
    super.key,
    required this.note,
    required this.onNoteUpdate,
    required this.onNoteDelete,
  });

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  // Debounce timer for auto-saving
  DateTime _lastEditTime = DateTime.now();
  bool _hasUnsavedChanges = false;
  
  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    
    // Add listeners for changes
    _titleController.addListener(_handleTextChange);
    _contentController.addListener(_handleTextChange);
  }
  
  @override
  void didUpdateWidget(NoteEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update controllers if the note changes
    if (oldWidget.note.id != widget.note.id) {
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
      _hasUnsavedChanges = false;
    }
  }
  
  void _handleTextChange() {
    setState(() {
      _hasUnsavedChanges = true;
      _lastEditTime = DateTime.now();
    });
    
    // Schedule a save after user stops typing for a moment
    Future.delayed(const Duration(milliseconds: 1000), () {
      final now = DateTime.now();
      if (now.difference(_lastEditTime).inMilliseconds >= 1000 && _hasUnsavedChanges) {
        _saveChanges();
      }
    });
  }
  
  void _saveChanges() {
    if (!_hasUnsavedChanges) return;
    
    final updatedNote = widget.note.copyWith(
      title: _titleController.text.trim().isEmpty ? 'Untitled Note' : _titleController.text,
      content: _contentController.text,
    );
    
    widget.onNoteUpdate(updatedNote);
    _hasUnsavedChanges = false;
  }
  
  void _confirmDeleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onNoteDelete(widget.note.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    // Save any pending changes
    if (_hasUnsavedChanges) {
      _saveChanges();
    }
    
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          TextField(
            controller: _titleController,
            style: theme.textTheme.titleLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Untitled Note',
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            maxLines: 1,
          ),
          
          // Display last edited time - more prominent now
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Last edited: ${_formatDate(widget.note.updatedAt)}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.primary.withOpacity(0.8),
              ),
            ),
          ),
          
          const Divider(),
          
          // Content field
          Expanded(
            child: TextField(
              controller: _contentController,
              style: theme.textTheme.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Write your note here...',
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              expands: true,
            ),
          ),
          
          // Save indicator
          if (_hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saving...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
