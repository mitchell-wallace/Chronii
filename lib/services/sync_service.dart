import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../models/timer_model.dart';
import '../models/note_model.dart';
import '../repositories/repository_factory.dart';
import '../repositories/base/todo_repository.dart';
import '../repositories/base/timer_repository.dart';
import '../repositories/base/note_repository.dart';
import '../repositories/local/local_todo_repository.dart';
import '../repositories/local/local_timer_repository.dart';
import '../repositories/local/local_note_repository.dart';
import '../repositories/firebase/firebase_todo_repository.dart';
import '../repositories/firebase/firebase_timer_repository.dart';
import '../repositories/firebase/firebase_note_repository.dart';

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
    await _synchronizeNotes();
  }

  /// Synchronize all data from cloud to local storage
  /// Used when a user logs out but we want to keep their data locally
  Future<void> synchronizeDataToLocal() async {
    await _synchronizeTodos(toCloud: false);
    await _synchronizeTimers(toCloud: false);
    await _synchronizeNotes(toCloud: false);
  }
  
  /// Synchronize todos between local and cloud storage using timestamp comparison
  Future<void> _synchronizeTodos({bool toCloud = true}) async {
    await _synchronizeItems<Todo>(
      localRepoFactory: () async => LocalTodoRepository(),
      cloudRepoFactory: () async => FirebaseTodoRepository(),
      toCloud: toCloud,
      itemType: 'todos',
    );
  }
 
  /// Synchronize timers between local and cloud storage using timestamp comparison
  Future<void> _synchronizeTimers({bool toCloud = true}) async {
    await _synchronizeItems<TaskTimer>(
      localRepoFactory: () async => LocalTimerRepository(),
      cloudRepoFactory: () async => FirebaseTimerRepository(),
      toCloud: toCloud,
      itemType: 'timers',
    );
  }
   
  /// Synchronize notes between local and cloud storage using timestamp comparison
  Future<void> _synchronizeNotes({bool toCloud = true}) async {
    await _synchronizeItems<Note>(
      localRepoFactory: () async => LocalNoteRepository(),
      cloudRepoFactory: () async => FirebaseNoteRepository(),
      toCloud: toCloud,
      itemType: 'notes',
    );
  }
  
  /// Generic function to synchronize items between local and cloud repositories
  /// based on their `updatedAt` timestamp.
  Future<void> _synchronizeItems<T>({ 
    required Future<dynamic> Function() localRepoFactory, // Returns BaseRepository<T> conceptually
    required Future<dynamic> Function() cloudRepoFactory, // Returns BaseRepository<T> conceptually
    required bool toCloud,
    required String itemType, // For logging
  }) async {
    try {
      // Get repositories
      final localRepo = await localRepoFactory();
      await localRepo.init();

      // Cloud requires authenticated user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) {
        debugPrint('Cannot sync $itemType: No authenticated (non-anonymous) user');
        return;
      }
      final cloudRepo = await cloudRepoFactory();
      await cloudRepo.init();

      // Fetch items
      final List<T> localItems = await localRepo.getAll();
      final List<T> cloudItems = await cloudRepo.getAll();

      // Create maps for easy lookup by ID
      // Assumes items have `id` and `updatedAt` properties
      final localMap = { for (var item in localItems) (item as dynamic).id : item };
      final cloudMap = { for (var item in cloudItems) (item as dynamic).id : item };

      int updatedCount = 0;
      int addedCount = 0;
      List<Future> syncFutures = [];

      if (toCloud) {
        // Sync Local -> Cloud
        for (final localItem in localItems) {
          final String localId = (localItem as dynamic).id;
          final DateTime localUpdatedAt = (localItem as dynamic).updatedAt;
          final cloudItem = cloudMap[localId];

          if (cloudItem == null) {
            // Item exists locally, not in cloud -> Add to cloud
            syncFutures.add(cloudRepo.add(localItem).then((_) => addedCount++));
          } else {
            // Item exists in both -> Compare timestamps
            final DateTime cloudUpdatedAt = (cloudItem as dynamic).updatedAt;
            if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
              // Local is newer -> Update cloud
              syncFutures.add(cloudRepo.update(localItem).then((_) => updatedCount++));
            }
            // If cloud is newer or same, do nothing for local -> cloud sync
          }
        }
        await Future.wait(syncFutures);
        if (addedCount > 0 || updatedCount > 0) {
          debugPrint('Synced $itemType to cloud: $addedCount added, $updatedCount updated.');
        }

        // Optional: Check cloud items not present locally (were they deleted locally?)

        // Optional: Clear local after sync? 
        // if (addedCount + updatedCount > 0 && itemType != 'notes') { // Maybe don't clear notes?
        //   List<Future> deleteFutures = localItems.map((item) => localRepo.delete((item as dynamic).id)).toList();
        //   await Future.wait(deleteFutures);
        //   debugPrint('Cleared $itemType from local storage after cloud sync.');
        // }

      } else {
        // Sync Cloud -> Local
        for (final cloudItem in cloudItems) {
          final String cloudId = (cloudItem as dynamic).id;
          final DateTime cloudUpdatedAt = (cloudItem as dynamic).updatedAt;
          final localItem = localMap[cloudId];

          if (localItem == null) {
            // Item exists in cloud, not locally -> Add locally
             syncFutures.add(localRepo.add(cloudItem).then((_) => addedCount++));
          } else {
            // Item exists in both -> Compare timestamps
            final DateTime localUpdatedAt = (localItem as dynamic).updatedAt;
            if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
               // Cloud is newer -> Update local
               syncFutures.add(localRepo.update(cloudItem).then((_) => updatedCount++));
            }
             // If local is newer or same, do nothing for cloud -> local sync
          }
        }
        await Future.wait(syncFutures);
        if (addedCount > 0 || updatedCount > 0) {
          debugPrint('Synced $itemType to local: $addedCount added, $updatedCount updated.');
        }
        
        // Optional: Check local items not present in cloud (were they deleted in cloud?)
        // For simplicity, we're not handling deletions initiated from the other side during this sync direction.
      }

    } catch (e, stackTrace) {
        debugPrint('Error synchronizing $itemType (${toCloud ? 'toCloud' : 'toLocal'}): $e');
        // Providing stack trace for better debugging
        debugPrintStack(label: 'SyncService Error', stackTrace: stackTrace); 
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
