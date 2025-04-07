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
  
  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Get all todos
  List<Todo> get todos => List.unmodifiable(_cachedTodos);
  
  /// Get completed todos
  List<Todo> get completedTodos => _cachedTodos.where((todo) => todo.isCompleted).toList();
  
  /// Get incomplete todos
  List<Todo> get incompleteTodos => _cachedTodos.where((todo) => !todo.isCompleted).toList();
  
  /// Get todos due today
  List<Todo> get todayTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _cachedTodos.where((todo) => 
      todo.dueDate != null && 
      DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day) == today
    ).toList();
  }
  
  /// Get todos due this week (not including today)
  List<Todo> get thisWeekTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekFromNow = today.add(const Duration(days: 7));
    
    return _cachedTodos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      return dueDate.isAfter(today) && dueDate.isBefore(weekFromNow) || dueDate == weekFromNow;
    }).toList();
  }
  
  /// Get overdue todos
  List<Todo> get overdueTodos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _cachedTodos.where((todo) {
      if (todo.dueDate == null || todo.isCompleted) return false;
      final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
      return dueDate.isBefore(today);
    }).toList();
  }
  
  /// Get todos with no due date
  List<Todo> get noDueDateTodos => _cachedTodos.where((todo) => todo.dueDate == null).toList();
  
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
    _isInitialized = true;
  }
  
  /// Add a new todo
  Future<Todo> addTodo(String title, {
    String? description,
    DateTime? dueDate,
    TodoPriority priority = TodoPriority.medium,
    List<String>? tags,
  }) async {
    final todo = Todo(
      title: title.trim(),
      description: description?.trim(),
      dueDate: dueDate,
      priority: priority,
      tags: tags,
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
  
  /// Update todo due date
  Future<bool> updateTodoDueDate(String todoId, DateTime? dueDate) async {
    final todo = getTodoById(todoId);
    if (todo == null) return false;
    
    final updatedTodo = todo.copyWith(dueDate: dueDate);
    return updateTodo(updatedTodo);
  }
  
  /// Update todo priority
  Future<bool> updateTodoPriority(String todoId, TodoPriority priority) async {
    final todo = getTodoById(todoId);
    if (todo == null) return false;
    
    final updatedTodo = todo.copyWith(priority: priority);
    return updateTodo(updatedTodo);
  }
  
  /// Add tag to todo
  Future<bool> addTagToTodo(String todoId, String tag) async {
    final todo = getTodoById(todoId);
    if (todo == null || tag.trim().isEmpty) return false;
    
    if (todo.tags.contains(tag.trim())) return true; // Already has this tag
    
    final updatedTags = List<String>.from(todo.tags)..add(tag.trim());
    final updatedTodo = todo.copyWith(tags: updatedTags);
    return updateTodo(updatedTodo);
  }
  
  /// Remove tag from todo
  Future<bool> removeTagFromTodo(String todoId, String tag) async {
    final todo = getTodoById(todoId);
    if (todo == null) return false;
    
    if (!todo.tags.contains(tag)) return true; // Doesn't have this tag
    
    final updatedTags = List<String>.from(todo.tags)..remove(tag);
    final updatedTodo = todo.copyWith(tags: updatedTags);
    return updateTodo(updatedTodo);
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
  
  /// Sort todos by due date
  void sortByDueDate({bool ascending = true}) {
    _cachedTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return ascending ? 1 : -1;
      if (b.dueDate == null) return ascending ? -1 : 1;
      return ascending
          ? a.dueDate!.compareTo(b.dueDate!)
          : b.dueDate!.compareTo(a.dueDate!);
    });
    notifyListeners();
  }
  
  /// Sort todos by priority
  void sortByPriority({bool highPriorityFirst = true}) {
    _cachedTodos.sort((a, b) {
      return highPriorityFirst
          ? b.priority.index.compareTo(a.priority.index)
          : a.priority.index.compareTo(b.priority.index);
    });
    notifyListeners();
  }
  
  /// Sort todos by completion status
  void sortByCompletionStatus({bool completedFirst = false}) {
    _cachedTodos.sort((a, b) => completedFirst
        ? (a.isCompleted ? -1 : 1).compareTo(b.isCompleted ? -1 : 1)
        : (a.isCompleted ? 1 : -1).compareTo(b.isCompleted ? 1 : -1));
    notifyListeners();
  }
  
  /// Filter todos by tag
  List<Todo> filterByTag(String tag) {
    return _cachedTodos.where((todo) => todo.tags.contains(tag)).toList();
  }
  
  /// Filter todos by priority
  List<Todo> filterByPriority(TodoPriority priority) {
    return _cachedTodos.where((todo) => todo.priority == priority).toList();
  }
  
  /// Get the number of completed todos
  int get completedCount => _cachedTodos.where((todo) => todo.isCompleted).length;
  
  /// Get the number of incomplete todos
  int get incompleteCount => _cachedTodos.where((todo) => !todo.isCompleted).length;
  
  /// Get the total number of todos
  int get totalCount => _cachedTodos.length;
  
  /// Get the number of overdue todos
  int get overdueCount => overdueTodos.length;
  
  /// Get all unique tags used across todos
  Set<String> get allTags {
    final tags = <String>{};
    for (final todo in _cachedTodos) {
      tags.addAll(todo.tags);
    }
    return tags;
  }
}