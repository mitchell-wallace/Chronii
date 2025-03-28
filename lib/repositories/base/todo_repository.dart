import '../../models/todo_model.dart';
import 'base_repository.dart';

/// Repository interface for Todo operations
/// Extends the base repository with Todo-specific operations
abstract class TodoRepository extends BaseRepository<Todo> {
  /// Get completed todos
  Future<List<Todo>> getCompleted();
  
  /// Get incomplete todos
  Future<List<Todo>> getIncomplete();
  
  /// Toggle completion status of a todo
  Future<bool> toggleCompletion(String id);
  
  /// Delete all completed todos
  Future<int> deleteCompleted();
  
  /// Mark all todos as completed
  Future<int> markAllAsCompleted();
  
  /// Mark all todos as incomplete
  Future<int> markAllAsIncomplete();
}
