import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import 'note_menu_actions.dart';

/// Widget for displaying notes in a grid view
class NoteGrid extends StatelessWidget {
  /// List of notes to display
  final List<Note> notes;
  
  /// Callback for when a note is selected
  final Function(Note) onNoteSelected;
  
  /// Callback for when a note is updated
  final Function(Note) onNoteUpdate;
  
  /// Callback for when a note is deleted
  final Function(String) onNoteDelete;

  const NoteGrid({
    super.key,
    required this.notes,
    required this.onNoteSelected,
    required this.onNoteUpdate,
    required this.onNoteDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Text('No notes available. Create a new note to get started.'),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _buildNoteCard(context, note);
        },
      ),
    );
  }
  
  Widget _buildNoteCard(BuildContext context, Note note) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onNoteSelected(note),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note title
            GestureDetector(
              onLongPressStart: (details) {
                // Show menu at the long press position
                NoteMenuUtil.showNoteMenuByLongPress(
                  context: context,
                  note: note,
                  details: details,
                  onToggleOpenState: () {
                    // Tell parent to toggle the note's open state
                    final updatedNote = note.copyWith(isOpen: !note.isOpen);
                    onNoteUpdate(updatedNote);
                  },
                  onDelete: () => _confirmDeleteNote(context, note),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: note.isOpen 
                    ? theme.colorScheme.primaryContainer.withOpacity(0.5)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Open/closed indicator
                    Icon(
                      note.isOpen ? Icons.visibility : Icons.visibility_off,
                      size: 16,
                      color: note.isOpen 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note.title.isEmpty ? 'Untitled Note' : note.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: note.isOpen
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    NoteMenuButton(
                      note: note,
                      onUpdate: (_) => onNoteSelected(note),
                      onDelete: () => _confirmDeleteNote(context, note),
                      onToggleOpenState: () {
                        // Tell parent to toggle the note's open state
                        final updatedNote = note.copyWith(isOpen: !note.isOpen);
                        onNoteUpdate(updatedNote);
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Note content preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  note.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            
            // Last edited
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Text(
                'Edited: ${_formatDate(note.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _confirmDeleteNote(BuildContext context, Note note) {
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
              onNoteDelete(note.id);
            },
            child: const Text('Delete'),
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
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
