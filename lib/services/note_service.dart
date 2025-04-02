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
