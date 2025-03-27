import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

/// Service for managing todos with persistence
class TodoService {
  static const String _storageKey = 'todos';
  List<Todo> _todos = [];
  
  /// Get all todos
  List<Todo> get todos => List.unmodifiable(_todos);
  
  /// Get completed todos
  List<Todo> get completedTodos => _todos.where((todo) => todo.isCompleted).toList();
  
  /// Get incomplete todos
  List<Todo> get incompleteTodos => _todos.where((todo) => !todo.isCompleted).toList();
  
  /// Initialize the service and load saved todos
  Future<void> init() async {
    await _loadTodos();
  }
  
  /// Load todos from persistent storage
  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = prefs.getString(_storageKey);
      
      if (todosJson != null) {
        final List<dynamic> decoded = jsonDecode(todosJson);
        _todos = decoded.map((json) => Todo.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading todos: $e');
      // If loading fails, we'll start with an empty list
      _todos = [];
    }
  }
  
  /// Save todos to persistent storage
  Future<void> _saveTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todosJson = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
      await prefs.setString(_storageKey, todosJson);
    } catch (e) {
      debugPrint('Error saving todos: $e');
    }
  }
  
  /// Add a new todo
  Future<Todo> addTodo(String title, {String? description}) async {
    final todo = Todo(
      title: title.trim(),
      description: description?.trim(),
    );
    
    _todos.add(todo);
    await _saveTodos();
    return todo;
  }
  
  /// Get a todo by ID
  Todo? getTodoById(String id) {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Update a todo
  Future<bool> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) return false;
    
    _todos[index] = updatedTodo;
    updatedTodo.updatedAt = DateTime.now();
    await _saveTodos();
    return true;
  }
  
  /// Toggle a todo's completion status
  Future<bool> toggleTodoCompletion(String todoId) async {
    final index = _todos.indexWhere((todo) => todo.id == todoId);
    if (index == -1) return false;
    
    _todos[index].toggleCompletion();
    await _saveTodos();
    return true;
  }
  
  /// Delete a todo
  Future<bool> deleteTodo(String todoId) async {
    final initialLength = _todos.length;
    _todos.removeWhere((todo) => todo.id == todoId);
    
    if (_todos.length != initialLength) {
      await _saveTodos();
      return true;
    }
    return false;
  }
  
  /// Delete all completed todos
  Future<int> deleteCompletedTodos() async {
    final initialLength = _todos.length;
    _todos.removeWhere((todo) => todo.isCompleted);
    
    final deletedCount = initialLength - _todos.length;
    if (deletedCount > 0) {
      await _saveTodos();
    }
    return deletedCount;
  }
  
  /// Mark all todos as completed
  Future<int> markAllAsCompleted() async {
    int count = 0;
    
    for (final todo in _todos) {
      if (!todo.isCompleted) {
        todo.complete();
        count++;
      }
    }
    
    if (count > 0) {
      await _saveTodos();
    }
    return count;
  }
  
  /// Mark all todos as incomplete
  Future<int> markAllAsIncomplete() async {
    int count = 0;
    
    for (final todo in _todos) {
      if (todo.isCompleted) {
        todo.uncomplete();
        count++;
      }
    }
    
    if (count > 0) {
      await _saveTodos();
    }
    return count;
  }
  
  /// Clear all todo data
  Future<void> clearAllTodos() async {
    _todos.clear();
    await _saveTodos();
  }
  
  /// Sort todos by creation date (newest first)
  void sortByCreationDate({bool ascending = false}) {
    _todos.sort((a, b) => ascending 
        ? a.createdAt.compareTo(b.createdAt) 
        : b.createdAt.compareTo(a.createdAt));
  }
  
  /// Sort todos by update date (newest first)
  void sortByUpdateDate({bool ascending = false}) {
    _todos.sort((a, b) => ascending 
        ? a.updatedAt.compareTo(b.updatedAt) 
        : b.updatedAt.compareTo(a.updatedAt));
  }
  
  /// Sort todos by completion status
  void sortByCompletionStatus({bool completedFirst = false}) {
    _todos.sort((a, b) => completedFirst
        ? (a.isCompleted ? -1 : 1).compareTo(b.isCompleted ? -1 : 1)
        : (a.isCompleted ? 1 : -1).compareTo(b.isCompleted ? 1 : -1));
  }
  
  /// Get the number of completed todos
  int get completedCount => _todos.where((todo) => todo.isCompleted).length;
  
  /// Get the number of incomplete todos
  int get incompleteCount => _todos.where((todo) => !todo.isCompleted).length;
  
  /// Get the total number of todos
  int get totalCount => _todos.length;
} 