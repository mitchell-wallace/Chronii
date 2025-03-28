import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/todo_model.dart';
import '../base/todo_repository.dart';

/// Implementation of TodoRepository that uses SharedPreferences for local storage
class LocalTodoRepository implements TodoRepository {
  static const String _storageKey = 'todos';
  List<Todo> _todos = [];
  
  @override
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
  
  @override
  Future<List<Todo>> getAll() async {
    return List.unmodifiable(_todos);
  }
  
  @override
  Future<Todo?> getById(String id) async {
    try {
      return _todos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<Todo> add(Todo todo) async {
    _todos.add(todo);
    await _saveTodos();
    return todo;
  }
  
  @override
  Future<bool> update(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) return false;
    
    _todos[index] = updatedTodo;
    updatedTodo.updatedAt = DateTime.now();
    await _saveTodos();
    return true;
  }
  
  @override
  Future<bool> delete(String id) async {
    final initialLength = _todos.length;
    _todos.removeWhere((todo) => todo.id == id);
    
    if (_todos.length != initialLength) {
      await _saveTodos();
      return true;
    }
    return false;
  }
  
  @override
  Future<List<Todo>> getCompleted() async {
    return _todos.where((todo) => todo.isCompleted).toList();
  }
  
  @override
  Future<List<Todo>> getIncomplete() async {
    return _todos.where((todo) => !todo.isCompleted).toList();
  }
  
  @override
  Future<bool> toggleCompletion(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return false;
    
    _todos[index].toggleCompletion();
    await _saveTodos();
    return true;
  }
  
  @override
  Future<int> deleteCompleted() async {
    final initialLength = _todos.length;
    _todos.removeWhere((todo) => todo.isCompleted);
    
    final deletedCount = initialLength - _todos.length;
    if (deletedCount > 0) {
      await _saveTodos();
    }
    return deletedCount;
  }
  
  @override
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
  
  @override
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
}
