import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../models/note_model.dart';
import '../base/note_repository.dart';

/// Firebase implementation of the note repository using Cloud Firestore
class FirebaseNoteRepository implements BaseNoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  String? _userId;
  CollectionReference? _notesCollection;

  // Allow dependency injection for testing
  FirebaseNoteRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<void> init() async {
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      _notesCollection = _firestore.collection('users').doc(_userId).collection('notes');
    } else {
      _userId = null;
      _notesCollection = null;
      // Optionally, throw an error or handle the unauthenticated state
      debugPrint('FirebaseNoteRepository initialized without an authenticated user.');
    }
  }

  /// Ensures the repository is initialized and user is authenticated
  bool _ensureInitialized() {
    if (_notesCollection == null || _userId == null) {
       debugPrint('FirebaseNoteRepository not initialized or user not authenticated.');
      // Attempt to re-initialize in case auth state changed
      // Note: This might not be sufficient in all scenarios
       final user = _auth.currentUser;
       if (user != null) {
         _userId = user.uid;
         _notesCollection = _firestore.collection('users').doc(_userId).collection('notes');
       } else {
         return false; // Still not initialized
       }
    }
    return true;
  }

  @override
  Future<void> add(Note note) async {
    if (!_ensureInitialized()) return;
    try {
      await _notesCollection!.doc(note.id).set(note.toJson());
    } catch (e) {
      debugPrint('Error adding note to Firebase: $e');
      rethrow; // Re-throw to allow service layer to handle
    }
  }

  @override
  Future<void> update(Note note) async {
    if (!_ensureInitialized()) return;
    try {
      await _notesCollection!.doc(note.id).update(note.toJson());
    } catch (e) {
      debugPrint('Error updating note in Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete(String id) async {
    if (!_ensureInitialized()) return;
    try {
      await _notesCollection!.doc(id).delete();
    } catch (e) {
      debugPrint('Error deleting note from Firebase: $e');
      rethrow;
    }
  }
  
  @override
  Future<Note?> getById(String id) async {
    if (!_ensureInitialized()) return null;
    try {
      final docSnapshot = await _notesCollection!.doc(id).get();
      if (docSnapshot.exists) {
        return Note.fromJson(docSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting note by ID from Firebase: $e');
      return null;
    }
  }

  @override
  Future<List<Note>> getAll() async {
    if (!_ensureInitialized()) return [];
    try {
      final querySnapshot = await _notesCollection!.orderBy('updatedAt', descending: true).get();
      return querySnapshot.docs
          .map((doc) => Note.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting all notes from Firebase: $e');
      return [];
    }
  }
}
