import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/note_model.dart';
import '../base/note_repository.dart';

/// Local implementation of the note repository using SharedPreferences
class LocalNoteRepository implements BaseNoteRepository {
  SharedPreferences? _prefs;
  static const String _storageKey = 'notes';
  List<Note> _notesCache = [];

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadNotesFromPrefs();
  }

  Future<void> _loadNotesFromPrefs() async {
    if (_prefs == null) await init();
    try {
      final jsonData = _prefs!.getStringList(_storageKey);
      if (jsonData != null) {
        _notesCache = jsonData
            .map((item) => Note.fromJson(json.decode(item)))
            .toList();
        _notesCache.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } else {
        _notesCache = [];
      }
    } catch (e) {
      debugPrint('Error loading notes from SharedPreferences: $e');
      _notesCache = [];
    }
  }

  Future<void> _saveNotesToPrefs() async {
    if (_prefs == null) await init();
    try {
      final jsonData = _notesCache
          .map((note) => json.encode(note.toJson()))
          .toList();
      await _prefs!.setStringList(_storageKey, jsonData);
    } catch (e) {
      debugPrint('Error saving notes to SharedPreferences: $e');
    }
  }

  @override
  Future<void> add(Note note) async {
    // Ensure the note doesn't already exist in the cache
    if (!_notesCache.any((n) => n.id == note.id)) {
      _notesCache.insert(0, note); // Add to beginning for recent sort order
      _notesCache.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Maintain sort order
      await _saveNotesToPrefs();
    }
  }

  @override
  Future<void> update(Note note) async {
    final index = _notesCache.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notesCache[index] = note;
      _notesCache.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Maintain sort order
      await _saveNotesToPrefs();
    }
  }

  @override
  Future<void> delete(String id) async {
    _notesCache.removeWhere((note) => note.id == id);
    await _saveNotesToPrefs();
  }
  
  @override
  Future<Note?> getById(String id) async {
     // Ensure cache is loaded
    if (_prefs == null) await _loadNotesFromPrefs();
    try {
      return _notesCache.firstWhere((note) => note.id == id);
    } catch (e) {
      return null; // Not found
    }
  }

  @override
  Future<List<Note>> getAll() async {
     // Ensure cache is loaded
    if (_prefs == null) await _loadNotesFromPrefs();
    // Return a copy to prevent external modification of the cache
    return List<Note>.from(_notesCache);
  }
}
