import 'package:flutter/material.dart';
import '../../models/note_model.dart';

/// Shared utility for showing note action menus
class NoteMenuUtil {
  /// Shows a menu with note actions
  static Future<void> showNoteMenu({
    required BuildContext context,
    required Note note,
    required Offset position,
    required VoidCallback onToggleOpenState,
    required VoidCallback onDelete,
    bool includeDelete = true,
  }) {
    // Calculate position for menu
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    // Show menu at the specified position
    return showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 1, 1),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      items: _buildMenuItems(note, includeDelete),
      elevation: 8,
    ).then((value) {
      if (value == 'toggle_state') {
        onToggleOpenState();
      } else if (value == 'delete') {
        onDelete();
      }
    });
  }
  
  /// Shows a menu with note actions at the tap position
  static Future<void> showNoteMenuAtTapPosition({
    required BuildContext context,
    required Note note,
    required TapDownDetails details,
    required VoidCallback onToggleOpenState,
    required VoidCallback onDelete,
    bool includeDelete = true,
  }) {
    // Use the tap position for menu
    return showNoteMenu(
      context: context,
      note: note,
      position: details.globalPosition,
      onToggleOpenState: onToggleOpenState,
      onDelete: onDelete,
      includeDelete: includeDelete,
    );
  }
  
  /// Shows a menu with note actions anchored to a widget
  static Future<void> showNoteMenuByLongPress({
    required BuildContext context,
    required Note note,
    required LongPressStartDetails details,
    required VoidCallback onToggleOpenState,
    required VoidCallback onDelete,
    bool includeDelete = true,
  }) {
    // Use the long press position for menu
    return showNoteMenu(
      context: context,
      note: note,
      position: details.globalPosition,
      onToggleOpenState: onToggleOpenState,
      onDelete: onDelete,
      includeDelete: includeDelete,
    );
  }
  
  /// Builds the menu items for a note
  static List<PopupMenuItem<String>> _buildMenuItems(Note note, bool includeDelete) {
    final List<PopupMenuItem<String>> items = [
      PopupMenuItem<String>(
        value: 'toggle_state',
        child: Row(
          children: [
            Icon(
              note.isOpen ? Icons.visibility_off : Icons.visibility,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(note.isOpen ? 'Close' : 'Open'),
          ],
        ),
      ),
    ];
    
    if (includeDelete) {
      items.add(
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              const Icon(Icons.delete, size: 18),
              const SizedBox(width: 8),
              const Text('Delete'),
            ],
          ),
        ),
      );
    }
    
    return items;
  }
}

/// A button to show the note options menu (three vertical dots)
class NoteMenuButton extends StatelessWidget {
  /// The note associated with this menu
  final Note note;

  /// Callback when the note is updated
  final Function(Note) onUpdate;

  /// Callback when the note is deleted
  final VoidCallback onDelete;
  
  /// Callback when the note's open state is toggled
  final VoidCallback? onToggleOpenState;
  
  /// Whether to include delete option
  final bool includeDelete;

  const NoteMenuButton({
    super.key,
    required this.note,
    required this.onUpdate,
    required this.onDelete,
    this.onToggleOpenState,
    this.includeDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (_) => NoteMenuUtil._buildMenuItems(note, includeDelete),
      onSelected: (value) {
        if (value == 'toggle_state') {
          if (onToggleOpenState != null) {
            onToggleOpenState!();
          } else {
            // Fallback to old behavior for compatibility
            onUpdate(note);
          }
        } else if (value == 'delete') {
          onDelete();
        }
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}
