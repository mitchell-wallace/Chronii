import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../models/timer_model.dart';
import '../repositories/repository_factory.dart';
import '../repositories/base/todo_repository.dart';
import '../repositories/base/timer_repository.dart';
import '../repositories/local/local_todo_repository.dart';
import '../repositories/local/local_timer_repository.dart';
import '../repositories/firebase/firebase_todo_repository.dart';
import '../repositories/firebase/firebase_timer_repository.dart';

/// Service that handles synchronization of data between local and cloud storage
/// Particularly useful when converting from anonymous to authenticated user
class SyncService {
  final RepositoryFactory _repositoryFactory;
  
  SyncService({
    RepositoryFactory? repositoryFactory,
  }) : _repositoryFactory = repositoryFactory ?? RepositoryFactory();
  
  /// Synchronize all data from local to cloud storage
  /// Used when an anonymous user signs in and we need to migrate their data
  Future<void> synchronizeDataToCloud() async {
    await _synchronizeTodos();
    await _synchronizeTimers();
  }

  /// Synchronize all data from cloud to local storage
  /// Used when a user logs out but we want to keep their data locally
  Future<void> synchronizeDataToLocal() async {
    await _synchronizeTodos(toCloud: false);
    await _synchronizeTimers(toCloud: false);
  }
  
  /// Synchronize todos between local and cloud storage
  Future<void> _synchronizeTodos({bool toCloud = true}) async {
    try {
      // Access both repositories directly to avoid the factory choosing based on auth state
      final localRepo = LocalTodoRepository();
      await localRepo.init();
      
      // For cloud sync, we need an authenticated user
      if (toCloud && FirebaseAuth.instance.currentUser == null) {
        debugPrint('Cannot sync to cloud: No authenticated user');
        return;
      }
      
      if (toCloud) {
        // Syncing from local to cloud
        final cloudRepo = FirebaseTodoRepository();
        await cloudRepo.init();
        
        // Get all local todos
        final todos = await localRepo.getAll();
        
        // Upload each todo to the cloud
        for (final todo in todos) {
          await cloudRepo.add(todo);
        }
        
        debugPrint('Successfully synchronized ${todos.length} todos to cloud');
      } else {
        // Syncing from cloud to local
        // This assumes the user was previously authenticated
        if (FirebaseAuth.instance.currentUser == null) {
          debugPrint('Cannot sync from cloud: No authenticated user');
          return;
        }
        
        final cloudRepo = FirebaseTodoRepository();
        await cloudRepo.init();
        
        // Get all cloud todos
        final todos = await cloudRepo.getAll();
        
        // Save each todo locally
        for (final todo in todos) {
          await localRepo.add(todo);
        }
        
        debugPrint('Successfully synchronized ${todos.length} todos to local storage');
      }
    } catch (e) {
      debugPrint('Error synchronizing todos: $e');
    }
  }
  
  /// Synchronize timers between local and cloud storage
  Future<void> _synchronizeTimers({bool toCloud = true}) async {
    try {
      // Access both repositories directly to avoid the factory choosing based on auth state
      final localRepo = LocalTimerRepository();
      await localRepo.init();
      
      // For cloud sync, we need an authenticated user
      if (toCloud && FirebaseAuth.instance.currentUser == null) {
        debugPrint('Cannot sync to cloud: No authenticated user');
        return;
      }
      
      if (toCloud) {
        // Syncing from local to cloud
        final cloudRepo = FirebaseTimerRepository();
        await cloudRepo.init();
        
        // Get all local timers
        final timers = await localRepo.getAll();
        
        // Upload each timer to the cloud
        for (final timer in timers) {
          await cloudRepo.add(timer);
        }
        
        debugPrint('Successfully synchronized ${timers.length} timers to cloud');
      } else {
        // Syncing from cloud to local
        // This assumes the user was previously authenticated
        if (FirebaseAuth.instance.currentUser == null) {
          debugPrint('Cannot sync from cloud: No authenticated user');
          return;
        }
        
        final cloudRepo = FirebaseTimerRepository();
        await cloudRepo.init();
        
        // Get all cloud timers
        final timers = await cloudRepo.getAll();
        
        // Save each timer locally
        for (final timer in timers) {
          await localRepo.add(timer);
        }
        
        debugPrint('Successfully synchronized ${timers.length} timers to local storage');
      }
    } catch (e) {
      debugPrint('Error synchronizing timers: $e');
    }
  }
  
  /// Merge data when there are conflicts
  /// This is a more sophisticated synchronization that handles conflicts
  /// between local and cloud data
  Future<void> mergeData() async {
    // This would implement a more sophisticated merging strategy
    // For now, we'll just use the simple synchronization
    await synchronizeDataToCloud();
  }
}
