import 'package:flutter/foundation.dart';

/// Model representing a todo task
class Todo {
  /// Unique identifier for the todo
  final String id;
  
  /// Title of the todo
  String title;
  
  /// Optional description for the todo
  String? description;
  
  /// Whether the todo is completed
  bool isCompleted;
  
  /// When the todo was created
  final DateTime createdAt;
  
  /// When the todo was last updated
  DateTime updatedAt;
  
  /// Constructor for creating a new todo
  Todo({
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();
  
  /// Marks the todo as completed
  void complete() {
    isCompleted = true;
    updatedAt = DateTime.now();
  }
  
  /// Marks the todo as not completed
  void uncomplete() {
    isCompleted = false;
    updatedAt = DateTime.now();
  }
  
  /// Toggles the completion status of the todo
  void toggleCompletion() {
    isCompleted = !isCompleted;
    updatedAt = DateTime.now();
  }
  
  /// Updates the title of the todo
  void updateTitle(String newTitle) {
    if (newTitle.trim().isEmpty) return;
    title = newTitle.trim();
    updatedAt = DateTime.now();
  }
  
  /// Updates the description of the todo
  void updateDescription(String? newDescription) {
    description = newDescription?.trim();
    updatedAt = DateTime.now();
  }
  
  /// Creates a copy of this todo with optional new values
  Todo copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? updatedAt,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  /// Converts todo to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
  
  /// Creates a todo from JSON data
  factory Todo.fromJson(Map<String, dynamic> json) {
    try {
      return Todo(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        isCompleted: json['isCompleted'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      debugPrint('Error parsing todo from JSON: $e');
      // Return a fallback todo if parsing fails
      return Todo(
        title: 'Error Loading Todo',
        isCompleted: false,
      );
    }
  }
  
  @override
  String toString() => 'Todo(id: $id, title: $title, completed: $isCompleted)';
} 