import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import 'note_menu_actions.dart';

/// Widget for editing a note
class NoteEditor extends StatefulWidget {
  /// The note to edit
  final Note note;
  
  /// Callback for when note is updated
  final Function(Note) onNoteUpdate;
  
  /// Callback for when note is deleted
  final Function(String) onNoteDelete;
  
  /// Callback for when the menu should be opened
  final VoidCallback? onOpenMenu;

  const NoteEditor({
    super.key,
    required this.note,
    required this.onNoteUpdate,
    required this.onNoteDelete,
    this.onOpenMenu,
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
    if (oldWidget.note.id != widget.note.id ||
        oldWidget.note.title != widget.note.title ||
        oldWidget.note.content != widget.note.content) {
      
      _titleController.text = widget.note.title;
      _contentController.text = widget.note.content;
      
      // Reset unsaved changes state
      _hasUnsavedChanges = false;
    }
  }
  
  void _handleTextChange() {
    // Mark as having unsaved changes
    setState(() {
      _hasUnsavedChanges = true;
      _lastEditTime = DateTime.now();
    });
    
    // Save changes after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      // Only save if the last edit was at least 500ms ago
      final now = DateTime.now();
      final diff = now.difference(_lastEditTime);
      if (diff.inMilliseconds >= 500 && _hasUnsavedChanges) {
        _saveChanges();
      }
    });
  }
  
  void _saveChanges() {
    if (!_hasUnsavedChanges) return;
    
    // Create updated note with the new title and content
    final updatedNote = widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
      updatedAt: DateTime.now(),
    );
    
    // Call the update callback
    widget.onNoteUpdate(updatedNote);
    
    // Reset unsaved changes flag
    setState(() {
      _hasUnsavedChanges = false;
    });
  }
  
  void _confirmDeleteNote() {
    // Save any pending changes first
    if (_hasUnsavedChanges) {
      _saveChanges();
    }
    
    widget.onNoteDelete(widget.note.id);
  }
  
  @override
  void dispose() {
    // Clean up controllers
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
        children: [
          // Title field with long-press to show actions
          GestureDetector(
            onLongPressStart: _showActionsMenu,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: _titleController,
                style: theme.textTheme.titleLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Untitled Note',
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 1,
              ),
            ),
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: _contentController,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your note here...',
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          
          // Status indicator for auto-save
          if (_hasUnsavedChanges)
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
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
  
  // Show actions menu on long press
  void _showActionsMenu(LongPressStartDetails details) {
    NoteMenuUtil.showNoteMenuByLongPress(
      context: context,
      note: widget.note,
      details: details,
      onToggleOpenState: _closeNote,
      onDelete: _confirmDeleteNote,
    );
  }
  
  // Close the current note
  void _closeNote() {
    final updatedNote = widget.note.copyWith(isOpen: false);
    widget.onNoteUpdate(updatedNote);
  }
}
