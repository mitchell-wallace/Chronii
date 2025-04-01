import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../repositories/base/todo_repository.dart';
import '../repositories/repository_factory.dart';

/// Service for managing todos
class TodoService extends ChangeNotifier {
  late TodoRepository _repository;
  final RepositoryFactory _repositoryFactory;
  List<Todo> _cachedTodos = [];
  bool _isInitialized = false;
  
  /// Get all todos
  List<Todo> get todos => List.unmodifiable(_cachedTodos);
  
  /// Get completed todos
  List<Todo> get completedTodos => _cachedTodos.where((todo) => todo.isCompleted).toList();
  
  /// Get incomplete todos
  List<Todo> get incompleteTodos => _cachedTodos.where((todo) => !todo.isCompleted).toList();
  
  /// Constructor
  TodoService({
    RepositoryFactory? repositoryFactory,
  }) : _repositoryFactory = repositoryFactory ?? RepositoryFactory();
  
  /// Initialize the service and load todos
  Future<void> init() async {
    if (_isInitialized) return;
    
    _repository = await _repositoryFactory.createTodoRepository();
    await _loadTodos();
    _isInitialized = true;
  }
  
  /// Load todos from the repository
  Future<void> _loadTodos() async {
    try {
      _cachedTodos = await _repository.getAll();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading todos: $e');
      _cachedTodos = [];
    }
  }
  
  /// Refresh the repository when authentication state changes
  Future<void> refreshRepository() async {
    _repository = await _repositoryFactory.createTodoRepository();
    await _loadTodos();
  }
  
  /// Add a new todo
  Future<Todo> addTodo(String title, {String? description}) async {
    final todo = Todo(
      title: title.trim(),
      description: description?.trim(),
    );
    
    await _repository.add(todo);
    await _loadTodos(); // Refresh the cache
    return todo;
  }
  
  /// Get a todo by ID
  Todo? getTodoById(String id) {
    try {
      return _cachedTodos.firstWhere((todo) => todo.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Update a todo
  Future<bool> updateTodo(Todo updatedTodo) async {
    final success = await _repository.update(updatedTodo);
    if (success) {
      await _loadTodos(); // Refresh the cache
    }
    return success;
  }
  
  /// Toggle a todo's completion status
  Future<bool> toggleTodoCompletion(String todoId) async {
    final success = await _repository.toggleCompletion(todoId);
    if (success) {
      await _loadTodos(); // Refresh the cache
    }
    return success;
  }
  
  /// Delete a todo
  Future<bool> deleteTodo(String todoId) async {
    final success = await _repository.delete(todoId);
    if (success) {
      await _loadTodos(); // Refresh the cache
    }
    return success;
  }
  
  /// Delete all completed todos
  Future<int> deleteCompletedTodos() async {
    final count = await _repository.deleteCompleted();
    await _loadTodos(); // Refresh the cache
    return count;
  }
  
  /// Mark all todos as completed
  Future<int> markAllAsCompleted() async {
    final count = await _repository.markAllAsCompleted();
    await _loadTodos(); // Refresh the cache
    return count;
  }
  
  /// Mark all todos as incomplete
  Future<int> markAllAsIncomplete() async {
    final count = await _repository.markAllAsIncomplete();
    await _loadTodos(); // Refresh the cache
    return count;
  }
  
  /// Clear all todo data
  Future<void> clearAllTodos() async {
    for (final todo in _cachedTodos) {
      await _repository.delete(todo.id);
    }
    _cachedTodos = [];
    notifyListeners();
  }
  
  /// Sort todos by creation date (newest first)
  void sortByCreationDate({bool ascending = false}) {
    _cachedTodos.sort((a, b) => ascending 
        ? a.createdAt.compareTo(b.createdAt) 
        : b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }
  
  /// Sort todos by update date (newest first)
  void sortByUpdateDate({bool ascending = false}) {
    _cachedTodos.sort((a, b) => ascending 
        ? a.updatedAt.compareTo(b.updatedAt) 
        : b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }
  
  /// Sort todos by completion status
  void sortByCompletionStatus({bool completedFirst = false}) {
    _cachedTodos.sort((a, b) => completedFirst
        ? (a.isCompleted ? -1 : 1).compareTo(b.isCompleted ? -1 : 1)
        : (a.isCompleted ? 1 : -1).compareTo(b.isCompleted ? 1 : -1));
    notifyListeners();
  }
  
  /// Get the number of completed todos
  int get completedCount => _cachedTodos.where((todo) => todo.isCompleted).length;
  
  /// Get the number of incomplete todos
  int get incompleteCount => _cachedTodos.where((todo) => !todo.isCompleted).length;
  
  /// Get the total number of todos
  int get totalCount => _cachedTodos.length;
}