import 'package:flutter/foundation.dart';

/// Model representing a text note
class Note {
  /// Unique identifier for the note
  final String id;
  
  /// Title of the note
  String title;
  
  /// Content of the note
  String content;
  
  /// When the note was created
  final DateTime createdAt;
  
  /// When the note was last updated
  DateTime updatedAt;
  
  /// Constructor for creating a new note
  Note({
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  /// Updates the title of the note
  void updateTitle(String newTitle) {
    if (newTitle.trim().isEmpty) return;
    title = newTitle.trim();
    updatedAt = DateTime.now();
  }
  
  /// Updates the content of the note
  void updateContent(String newContent) {
    content = newContent;
    updatedAt = DateTime.now();
  }
  
  /// Creates a copy of this note with optional new values
  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// Converts note to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Creates a note from JSON data
  factory Note.fromJson(Map<String, dynamic> json) {
    try {
      return Note(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('Error parsing note from JSON: $e');
      // Return a fallback note if parsing fails
      return Note(
        title: 'Error Loading Note',
        content: 'There was an error loading this note.',
      );
    }
  }
  
  @override
  String toString() => 'Note(id: $id, title: $title)';
}
