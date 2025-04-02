import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../widgets/base/base_empty_state.dart';
import '../widgets/note/note_editor.dart';
import '../widgets/note/note_grid.dart';
import '../widgets/note/note_menu_actions.dart';

/// Screen for displaying and managing notes
class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> with TickerProviderStateMixin {
  // Note service
  final NoteService _noteService = NoteService();
  
  // Tab controller for note tabs
  late TabController _tabController;
  
  // Loading state
  bool _isLoading = true;
  
  // View mode (editor or grid)
  bool _isGridMode = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller with empty tabs initially
    _tabController = TabController(length: 0, vsync: this);
    
    // Initialize note service
    _initNoteService();
  }
  
  Future<void> _initNoteService() async {
    setState(() {
      _isLoading = true;
    });
    
    await _noteService.init();
    
    // Initialize tab controller with actual number of notes
    _updateTabController();
    
    setState(() {
      _isLoading = false;
    });
    
    // Create a default note if no notes exist
    if (_noteService.notes.isEmpty) {
      await _createNewNote();
    }
  }
  
  void _updateTabController() {
    final noteCount = _noteService.notes.length;
    
    if (noteCount == 0) {
      // If no notes, create a controller with just 1 tab
      _tabController = TabController(length: 1, vsync: this);
    } else {
      // Create controller with the right number of tabs
      _tabController = TabController(length: noteCount, vsync: this);
    }
  }
  
  Future<void> _createNewNote() async {
    final newNote = await _noteService.addNote('Untitled Note', '');
    
    // Update tab controller and select the new tab
    _updateTabController();
    _tabController.animateTo(0); // Newly added notes go to index 0
    
    setState(() {});
  }
  
  Future<void> _updateNote(Note updatedNote) async {
    await _noteService.updateNote(updatedNote);
    setState(() {});
  }
  
  Future<void> _deleteNote(String id) async {
    final noteIndex = _noteService.notes.indexWhere((note) => note.id == id);
    
    await _noteService.deleteNote(id);
    
    // Update tab controller after deletion
    _updateTabController();
    
    // If we deleted the last note or if the tab controller is now empty
    if (_noteService.notes.isEmpty) {
      await _createNewNote(); // Create a new default note
    } else {
      // Select an appropriate tab after deletion
      final newIndex = noteIndex == 0 ? 0 : noteIndex - 1;
      _tabController.animateTo(newIndex.clamp(0, _noteService.notes.length - 1));
    }
    
    setState(() {});
  }
  
  void _toggleViewMode() {
    setState(() {
      _isGridMode = !_isGridMode;
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = _noteService.notes;
    
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (notes.isEmpty && !_isGridMode) {
      return const BaseEmptyState(
        icon: Icons.note_alt_outlined,
        message: 'No notes yet',
        subMessage: 'Create a note to get started',
      );
    }
    
    return Column(
      children: [
        // Top action bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              // New note button
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'New Note',
                onPressed: _createNewNote,
              ),
              
              const SizedBox(width: 8),
              
              // Grid/Editor view toggle
              IconButton(
                icon: Icon(_isGridMode ? Icons.view_agenda : Icons.grid_view),
                tooltip: _isGridMode ? 'Editor View' : 'Grid View',
                onPressed: _toggleViewMode,
              ),
              
              // Spacer to push actions to the right
              const Spacer(),
              
              // Note menu button (only in editor mode and when there are notes)
              if (!_isGridMode && _noteService.notes.isNotEmpty)
                NoteMenuButton(
                  note: _noteService.notes[_tabController.index],
                  onUpdate: (_) {}, // No action needed as we're already in edit mode
                  onDelete: () {
                    if (_noteService.notes.isEmpty) return;
                    
                    final currentNoteIndex = _tabController.index;
                    if (currentNoteIndex >= 0 && currentNoteIndex < _noteService.notes.length) {
                      final currentNoteId = _noteService.notes[currentNoteIndex].id;
                      _deleteNote(currentNoteId);
                    }
                  },
                  includeDelete: true,
                ),
            ],
          ),
        ),
        
        // Display either grid or editor with tabs
        Expanded(
          child: _isGridMode 
            ? NoteGrid(
                notes: notes,
                onNoteSelected: (note) {
                  // When note is selected from grid, switch to editor view
                  final index = notes.indexOf(note);
                  _tabController.animateTo(index);
                  setState(() {
                    _isGridMode = false;
                  });
                },
                onNoteUpdate: _updateNote,
                onNoteDelete: _deleteNote,
              )
            : _buildTabView(notes, theme),
        ),
      ],
    );
  }
  
  Widget _buildTabView(List<Note> notes, ThemeData theme) {
    // Handle empty list case
    if (notes.isEmpty) {
      return const Center(
        child: Text('No notes available. Create a new note to get started.'),
      );
    }
    
    return Column(
      children: [
        // Thin tab bar for notes
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            dividerColor: Colors.transparent,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2.0,
                color: theme.colorScheme.primary,
              ),
            ),
            tabs: notes.map((note) => _buildNoteTab(note, theme)).toList(),
          ),
        ),
        
        // Tab content (note editors)
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: notes.map((note) => NoteEditor(
              note: note,
              onNoteUpdate: _updateNote,
              onNoteDelete: _deleteNote,
            )).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNoteTab(Note note, ThemeData theme) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            note.title.isEmpty ? 'Untitled Note' : note.title,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 4),
          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary.withOpacity(0.5)),
        ],
      ),
    );
  }
}
