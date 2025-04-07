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
  
  // Tab controller for switching between notes in edit view
  late TabController _tabController;
  
  // Flag to track if tab controller is initialized
  bool _isTabControllerInitialized = false;
  
  // Loading state
  bool _isLoading = true;
  
  // View mode (editor or grid)
  bool _isGridMode = false;

  @override
  void initState() {
    super.initState();
    
    // Create an initial controller with zero length
    // This will be updated after notes are loaded
    _tabController = TabController(length: 1, vsync: this);
    
    _initNoteService();
  }
  
  // Initialize the note service
  Future<void> _initNoteService() async {
    _isLoading = true;
    
    // Init the service
    await _noteService.init();
    
    // Ensure at least one note is open
    await _noteService.ensureOpenNote();
    
    // Listen for changes to the notes list
    _noteService.addListener(_updateTabController);
    
    // Initialize the tab controller after notes are loaded
    _updateTabController();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  // Update the tab controller when notes change
  void _updateTabController() {
    // Get the currently open notes
    final openNotes = _noteService.openNotes;
    final openNoteCount = openNotes.length;
    
    // Store current tab index to restore it later if possible
    final currentIndex = _isTabControllerInitialized ? _tabController.index : 0;
    
    // Dispose the old controller
    if (_isTabControllerInitialized) {
      _tabController.dispose();
    }
    
    if (openNoteCount == 0) {
      // If no open notes, create a controller with just 1 tab
      _tabController = TabController(length: 1, vsync: this);
    } else {
      // Create a controller with the correct number of tabs
      _tabController = TabController(
        length: openNoteCount,
        vsync: this,
        initialIndex: currentIndex < openNoteCount ? currentIndex : 0,
      );
    }
    
    _isTabControllerInitialized = true;
    
    // Force a rebuild
    if (mounted) {
      setState(() {});
    }
  }
  
  // Create a new note
  void _createNewNote() {
    _noteService.addNote('', '');
    
    // Switch to edit mode if in grid mode
    if (_isGridMode) {
      setState(() {
        _isGridMode = false;
      });
    }
    
    // Ensure the new note is shown in the editor
    final openNotes = _noteService.openNotes;
    if (openNotes.isNotEmpty) {
      // Switch to the last tab (the new note)
      _tabController.animateTo(openNotes.length - 1);
    }
  }
  
  // Update a note
  void _updateNote(Note updatedNote) {
    _noteService.updateNote(updatedNote);
  }
  
  // Toggle a note's open state
  void _toggleNoteOpenState(String id) {
    _noteService.toggleNoteOpenState(id);
  }
  
  // Delete a note
  void _deleteNote(String id) {
    _noteService.deleteNote(id);
  }
  
  // Close all notes except the current one
  void _closeAllNotesExceptCurrent() {
    final currentIndex = _tabController.index;
    final currentNote = _noteService.openNotes[currentIndex];
    _noteService.closeAllNotesExcept(currentNote.id);
  }
  
  // Open all notes
  void _openAllNotes() {
    _noteService.openAllNotes();
  }
  
  // Toggle between grid and editor view
  void _toggleViewMode() {
    setState(() {
      _isGridMode = !_isGridMode;
    });
  }
  
  @override
  void dispose() {
    _noteService.removeListener(_updateTabController);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notes = _noteService.notes;
    final openNotes = _noteService.openNotes;
    
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              
              const Spacer(),
              
              // Add the note menu button on the right
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Note options',
                onSelected: (value) {
                  // Handle selected menu item
                  if (value == 'create') {
                    _createNewNote();
                  } else if (value == 'close_all') {
                    _closeAllNotesExceptCurrent();
                  } else if (value == 'open_all') {
                    _openAllNotes();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'create',
                    child: Row(
                      children: [
                        Icon(Icons.note_add),
                        SizedBox(width: 8),
                        Text('New Note'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'open_all',
                    child: Row(
                      children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('Open All Notes'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'close_all',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off),
                        SizedBox(width: 8),
                        Text('Close Other Notes'),
                      ],
                    ),
                  ),
                ],
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
                  // If note is closed, open it first
                  if (!note.isOpen) {
                    final updatedNote = note.copyWith(isOpen: true);
                    _updateNote(updatedNote);
                  }
                  
                  // Find index in openNotes
                  final index = _noteService.openNotes.indexWhere((n) => n.id == note.id);
                  if (index >= 0) {
                    _tabController.animateTo(index);
                  }
                  
                  setState(() {
                    _isGridMode = false;
                  });
                },
                onNoteUpdate: _updateNote,
                onNoteDelete: _deleteNote,
              )
            : _buildTabView(openNotes, theme),
        ),
      ],
    );
  }
  
  Widget _buildTabView(List<Note> notes, ThemeData theme) {
    // Handle empty list case
    if (notes.isEmpty) {
      return const Center(
        child: Text('No open notes available. Create a new note to get started.'),
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
    return GestureDetector(
      onLongPressStart: (details) {
        // When long-pressing a tab, we want to handle it directly here
        // First ensure the tab is selected
        final index = _noteService.openNotes.indexOf(note);
        if (index >= 0 && index != _tabController.index) {
          _tabController.animateTo(index);
        }
        
        // Show menu at the long press position
        NoteMenuUtil.showNoteMenuByLongPress(
          context: context,
          note: note,
          details: details,
          onToggleOpenState: () => _toggleNoteOpenState(note.id),
          onDelete: () => _deleteNote(note.id),
        );
      },
      child: Tab(
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
      ),
    );
  }
}
