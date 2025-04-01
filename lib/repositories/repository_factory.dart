import 'package:firebase_auth/firebase_auth.dart';
import 'base/todo_repository.dart';
import 'base/timer_repository.dart';
import 'local/local_todo_repository.dart';
import 'local/local_timer_repository.dart';
import 'firebase/firebase_todo_repository.dart';
import 'firebase/firebase_timer_repository.dart';

/// Factory for creating repository instances based on authentication state
/// Provides the correct implementation (local or firebase) based on whether
/// the user is authenticated
class RepositoryFactory {
  final FirebaseAuth _auth;
  
  // Singleton instance
  static final RepositoryFactory _instance = RepositoryFactory._internal();
  
  // Private constructor for singleton
  RepositoryFactory._internal() : _auth = FirebaseAuth.instance;
  
  // Factory constructor to return the singleton
  factory RepositoryFactory() {
    return _instance;
  }
  
  /// Creates a TodoRepository based on authentication state
  Future<TodoRepository> createTodoRepository() async {
    final user = _auth.currentUser;
    TodoRepository repository;
    
    if (user != null && !user.isAnonymous) {
      // Authenticated user - use Firebase
      repository = FirebaseTodoRepository();
    } else {
      // Anonymous user - use local storage
      repository = LocalTodoRepository();
    }
    
    await repository.init();
    return repository;
  }
  
  /// Creates a TimerRepository based on authentication state
  Future<TimerRepository> createTimerRepository() async {
    final user = _auth.currentUser;
    TimerRepository repository;
    
    if (user != null && !user.isAnonymous) {
      // Authenticated user - use Firebase
      repository = FirebaseTimerRepository();
    } else {
      // Anonymous user - use local storage
      repository = LocalTimerRepository();
    }
    
    await repository.init();
    return repository;
  }
}
