import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note_model.dart';

/// Service for managing notes
class NoteService extends ChangeNotifier {
  // Singleton pattern
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  // List of notes
  List<Note> _notes = [];
  bool _initialized = false;
  static const String _storageKey = 'notes';
  
  /// Get all notes
  List<Note> get notes => _notes;
  
  /// Get only open notes
  List<Note> get openNotes => _notes.where((note) => note.isOpen).toList();
  
  /// Initialize the service
  Future<void> init() async {
    if (_initialized) return;
    
    await _loadNotes();
    _initialized = true;
  }
  
  /// Loads notes from local storage
  Future<void> _loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getStringList(_storageKey);
      
      if (jsonData != null) {
        _notes = jsonData
            .map((item) => Note.fromJson(json.decode(item)))
            .toList();
        
        // Sort notes by updated time (most recent first)
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } catch (e) {
      debugPrint('Error loading notes: $e');
      _notes = [];
    }
    
    notifyListeners();
  }
  
  /// Saves notes to local storage
  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = _notes
          .map((note) => json.encode(note.toJson()))
          .toList();
      
      await prefs.setStringList(_storageKey, jsonData);
    } catch (e) {
      debugPrint('Error saving notes: $e');
    }
  }
  
  /// Add a new note
  Future<Note> addNote(String title, String content) async {
    final note = Note(
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      isOpen: true,
    );
    
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
    
    return note;
  }
  
  /// Get a note by id
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Update a note
  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    
    if (index != -1) {
      _notes[index] = updatedNote;
      await _saveNotes();
      notifyListeners();
    }
  }
  
  /// Toggle a note's open/closed state
  Future<void> toggleNoteOpenState(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index == -1) return;
    
    // Get the note and toggle its state
    final note = _notes[index];
    note.toggleOpenState();
    
    // If we're closing the last open note, open another one
    ensureOpenNote();
    
    notifyListeners();
    await _saveNotes();
  }
  
  /// Close all notes except one with the given ID
  Future<void> closeAllNotesExcept(String id) async {
    // Update all notes to be closed except the one with the given ID
    for (int i = 0; i < _notes.length; i++) {
      if (_notes[i].id != id && _notes[i].isOpen) {
        _notes[i] = _notes[i].copyWith(isOpen: false);
      } else if (_notes[i].id == id && !_notes[i].isOpen) {
        // Make sure the excepted note is open
        _notes[i] = _notes[i].copyWith(isOpen: true);
      }
    }
    
    notifyListeners();
    await _saveNotes();
  }
  
  /// Open all notes
  Future<void> openAllNotes() async {
    // Update all notes to be open
    for (int i = 0; i < _notes.length; i++) {
      if (!_notes[i].isOpen) {
        _notes[i] = _notes[i].copyWith(isOpen: true);
      }
    }
    
    notifyListeners();
    await _saveNotes();
  }
  
  /// Ensure at least one note is open
  Future<void> ensureOpenNote() async {
    if (openNotes.isEmpty) {
      // If we have notes but none are open, open the most recently updated one
      if (_notes.isNotEmpty) {
        _notes[0].isOpen = true;
        await _saveNotes();
      } else {
        // If no notes at all, create a new one
        await addNote('Untitled Note', '');
      }
      
      notifyListeners();
    }
  }
  
  /// Delete a note
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
    notifyListeners();
  }
  
  /// Refresh repository
  Future<void> refreshRepository() async {
    await _loadNotes();
  }
}
