import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../repositories/repository_factory.dart';
import '../repositories/base/note_repository.dart';
import 'dart:async';

/// Service for managing notes
class NoteService extends ChangeNotifier {
  // Singleton pattern - keeping for now, though direct instantiation might be cleaner with DI
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal({RepositoryFactory? repositoryFactory}) 
      : _repositoryFactory = repositoryFactory ?? RepositoryFactory();

  // Dependencies
  final RepositoryFactory _repositoryFactory;
  BaseNoteRepository? _repository;

  // State
  List<Note> _notes = [];
  
  // Debouncing timer for note updates
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(seconds: 2); // 2-second debounce

  /// Get all notes (from cache)
  List<Note> get notes => _notes;
  
  /// Get only open notes (from cache)
  List<Note> get openNotes => _notes.where((note) => note.isOpen).toList();
  
  /// Initialize the service by getting the correct repository
  Future<void> init() async {
    _repository = await _repositoryFactory.createNoteRepository();
    await _loadNotesFromRepo();
  }
  
  /// Loads notes from the repository into the cache
  Future<void> _loadNotesFromRepo() async {
    if (_repository == null) {
      debugPrint('Note repository not initialized before loading.');
      await init(); // Attempt to initialize if not already
      if (_repository == null) { // Check again after init attempt
         debugPrint('Failed to initialize note repository.');
         _notes = [];
         notifyListeners();
         return;
      }
    }
    try {
      _notes = await _repository!.getAll();
      // Sort notes by updated time (most recent first)
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      debugPrint('Error loading notes from repository: $e');
      _notes = [];
    }
    notifyListeners();
  }

  /// Add a new note
  /// Returns the newly added note
  Future<Note> addNote(String title, String content) async {
    final note = Note(
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      isOpen: true, // New notes are open by default
    );
    
    try {
      await _repository?.add(note);
      
      // Add to local cache only after successful repo add
      _notes.insert(0, note); // Add at the beginning
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Keep cache sorted
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding note via repository: $e');
      // Optionally re-throw or handle the error appropriately
    }
    return note;
  }
  
  /// Get a note by id (from cache)
  Note? getNoteById(String id) {
    try {
      // Primarily rely on the cache for synchronous access
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      // Optionally, could try fetching from repo if not in cache, but adds async complexity
      // debugPrint('Note $id not found in cache.');
      return null;
    }
  }
  
  /// Update a note with debouncing
  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    
    if (index != -1) {
      // Update local cache immediately for responsiveness
      // Ensure updatedAt is current before potential save
      final noteToCache = updatedNote.copyWith(updatedAt: DateTime.now());
      _notes[index] = noteToCache;
      _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Keep cache sorted
      notifyListeners(); // Update UI immediately

      // Debounce the repository update
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () async {
        try {
          await _repository?.update(noteToCache); // Save the cached version
          // Silent save - no debug logs
        } catch (e) {
          debugPrint('Error updating note via repository after debounce: $e');
          // Optional: Implement retry or notify user
        }
      });
    }
  }
  
  /// Toggle a note's open/closed state
  Future<void> toggleNoteOpenState(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) return;
    
    // Get the note and toggle its state (this also updates 'updatedAt')
    final note = _notes[index];
    note.toggleOpenState(); // Modifies the note object directly
    
    try {
      await _repository?.update(note); // Save the modified note
      // State already updated in the cache object, just notify
      // Ensure open note logic needs to be called *after* potential repo update
      await ensureOpenNote(); // This might trigger another update/notify
      notifyListeners(); // Notify after all potential changes
      // Cancel any pending debounced save for this note, as toggle is immediate
      if (note.id == _notes[index].id) { 
         _debounceTimer?.cancel();
      }
    } catch (e) {
      debugPrint('Error updating note state via repository: $e');
      // Consider reverting the local state change if repo update fails
      note.toggleOpenState(); // Revert toggle
    }
  }
  
  /// Close all notes except one with the given ID
  Future<void> closeAllNotesExcept(String id) async {
    List<Note> notesToUpdate = [];
    bool changed = false;
    
    for (int i = 0; i < _notes.length; i++) {
      bool shouldBeOpen = _notes[i].id == id;
      if (_notes[i].isOpen != shouldBeOpen) {
        // Create a new instance with updated state and time
        _notes[i] = _notes[i].copyWith(isOpen: shouldBeOpen, updatedAt: DateTime.now());
        notesToUpdate.add(_notes[i]);
        changed = true;
      }
    }
    
    if (changed) {
      try {
        // Update all changed notes in the repository
        await Future.wait(notesToUpdate.map((note) => _repository!.update(note)));
        notifyListeners();
      } catch (e) {
        debugPrint('Error bulk updating note states via repository: $e');
        // Consider reverting local changes or implementing retry logic
         await _loadNotesFromRepo(); // Revert local state by reloading from repo
      }
      // Cancel pending saves if bulk update occurred
      _debounceTimer?.cancel(); 
    }
  }
  
  /// Open all notes
  Future<void> openAllNotes() async {
    List<Note> notesToUpdate = [];
    bool changed = false;

    for (int i = 0; i < _notes.length; i++) {
      if (!_notes[i].isOpen) {
         _notes[i] = _notes[i].copyWith(isOpen: true, updatedAt: DateTime.now());
         notesToUpdate.add(_notes[i]);
         changed = true;
      }
    }

     if (changed) {
      try {
        await Future.wait(notesToUpdate.map((note) => _repository!.update(note)));
        notifyListeners();
      } catch (e) {
        debugPrint('Error bulk opening notes via repository: $e');
        await _loadNotesFromRepo(); // Revert local state
      }
      // Cancel pending saves if bulk update occurred
      _debounceTimer?.cancel();
    }
  }
  
  /// Ensure at least one note is open
  Future<void> ensureOpenNote() async {
    if (openNotes.isEmpty) {
      Note? noteToUpdate;
      if (_notes.isNotEmpty) {
        // If we have notes but none are open, open the most recently updated one
        _notes[0] = _notes[0].copyWith(isOpen: true, updatedAt: DateTime.now());
        noteToUpdate = _notes[0];
      } 
      
      try {
        if (noteToUpdate != null) {
           await _repository?.update(noteToUpdate);
        } else {
           // If no notes at all, create a new one
           await addNote('Untitled Note', ''); // addNote handles repo + cache update + notify
           return; // Return early as addNote already notified
        }
        notifyListeners();
      } catch (e) {
         debugPrint('Error ensuring open note via repository: $e');
         await _loadNotesFromRepo(); // Revert local state
      }
    }
  }
  
  /// Cancel any pending debounced save before deleting
  void _cancelDebounceIfActive(String noteId) {
    // This check is basic; a more robust way might involve storing the ID
    // in the debounce closure, but this avoids extra complexity for now.
    _debounceTimer?.cancel();
  }
  
  /// Delete a note
  Future<void> deleteNote(String id) async {
    try {
      _cancelDebounceIfActive(id); // Cancel pending save for this note
      await _repository?.delete(id);
      // Remove from cache only after successful repo delete
      final originalLength = _notes.length;
      _notes.removeWhere((note) => note.id == id);
      if (_notes.length < originalLength) { // Check if something was actually removed
         await ensureOpenNote(); // Ensure one is still open if needed
         notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting note via repository: $e');
    }
  }
  
  /// Refresh repository and reload cache (e.g., after auth change)
  Future<void> refreshRepository() async {
    // Get potentially new repository based on auth state
    _repository = await _repositoryFactory.createNoteRepository(); 
    await _loadNotesFromRepo(); // Reload data into cache
  }
  
  // Ensure the debounce timer is cancelled when the service is disposed
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
