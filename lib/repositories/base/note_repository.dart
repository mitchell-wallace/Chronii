import '../../models/note_model.dart';

/// Base interface for note repositories
/// Defines the contract for accessing note data, whether locally or from the cloud
abstract class BaseNoteRepository {
  /// Initialize the repository (e.g., open database, setup listeners)
  Future<void> init();

  /// Add a new note
  Future<void> add(Note note);

  /// Update an existing note
  Future<void> update(Note note);

  /// Delete a note by its ID
  Future<void> delete(String id);
  
  /// Get a note by its ID
  Future<Note?> getById(String id);

  /// Get all notes
  Future<List<Note>> getAll();
}
