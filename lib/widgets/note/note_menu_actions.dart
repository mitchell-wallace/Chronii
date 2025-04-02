import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../base/base_menu_actions.dart';

/// A button to show the note options menu (three vertical dots)
class NoteMenuButton extends StatelessWidget {
  /// The note associated with this menu
  final Note note;

  /// Callback when the note is updated
  final Function(Note) onUpdate;

  /// Callback when the note is deleted
  final VoidCallback onDelete;
  
  /// Whether to include delete option
  final bool includeDelete;

  /// Constructor
  const NoteMenuButton({
    super.key,
    required this.note,
    required this.onUpdate,
    required this.onDelete,
    this.includeDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = <PopupMenuItem<String>>[];
    
    // Edit option
    menuItems.add(
      BaseMenuButton.createMenuItem(
        value: 'edit',
        icon: Icons.edit,
        text: 'Edit',
      ),
    );
    
    // Delete option (if included)
    if (includeDelete) {
      menuItems.add(
        BaseMenuButton.createMenuItem(
          value: 'delete',
          icon: Icons.delete,
          text: 'Delete',
        ),
      );
    }
    
    return BaseMenuButton(
      items: menuItems,
      onSelected: (value) {
        if (value == 'edit') {
          // For now, just select the note to edit (handled by parent)
          onUpdate(note);
        } else if (value == 'delete') {
          onDelete();
        }
      },
    );
  }
}
