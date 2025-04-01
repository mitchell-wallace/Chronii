import 'package:flutter/foundation.dart';
import '../models/timer_model.dart';
import '../repositories/base/timer_repository.dart';
import '../repositories/repository_factory.dart';

/// Service for managing timers
class TimerService extends ChangeNotifier {
  late TimerRepository _repository;
  final RepositoryFactory _repositoryFactory;
  List<TaskTimer> _cachedTimers = [];
  bool _isInitialized = false;
  
  /// Get all timers
  List<TaskTimer> get timers => List.unmodifiable(_cachedTimers);
  
  /// Constructor
  TimerService({
    RepositoryFactory? repositoryFactory,
  }) : _repositoryFactory = repositoryFactory ?? RepositoryFactory();
  
  /// Initialize the service and load timers
  Future<void> init() async {
    if (_isInitialized) return;
    
    _repository = await _repositoryFactory.createTimerRepository();
    await _loadTimers();
    _isInitialized = true;
  }
  
  /// Load timers from the repository
  Future<void> _loadTimers() async {
    try {
      _cachedTimers = await _repository.getAll();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading timers: $e');
      _cachedTimers = [];
    }
  }
  
  /// Refresh the repository when authentication state changes
  Future<void> refreshRepository() async {
    _repository = await _repositoryFactory.createTimerRepository();
    await _loadTimers();
  }
  
  /// Add a new timer
  Future<TaskTimer> addTimer(String name) async {
    final timer = TaskTimer(
      name: name.trim(),
      startTime: DateTime.now(),
    );
    
    await _repository.add(timer);
    await _loadTimers(); // Refresh the cache
    return timer;
  }
  
  /// Update an existing timer
  Future<bool> updateTimer(TaskTimer updatedTimer) async {
    final success = await _repository.update(updatedTimer);
    if (success) {
      await _loadTimers(); // Refresh the cache
    }
    return success;
  }
  
  /// Toggle a timer's running state
  /// If timer is running, it will be stopped
  /// If timer is stopped, a new timer with the same name will be created
  Future<TaskTimer?> toggleTimer(String timerId) async {
    final result = await _repository.toggleTimer(timerId);
    await _loadTimers(); // Refresh the cache
    return result;
  }
  
  /// Delete a timer
  Future<bool> deleteTimer(String timerId) async {
    final success = await _repository.delete(timerId);
    if (success) {
      await _loadTimers(); // Refresh the cache
    }
    return success;
  }
  
  /// Calculate total duration of given timer IDs
  Duration calculateTotalDuration(List<String> timerIds) {
    final now = DateTime.now();
    return _repository.calculateTotalDuration(timerIds, now);
  }
  
  /// Get all currently running timers
  Future<List<TaskTimer>> getRunningTimers() async {
    return _repository.getRunningTimers();
  }
  
  /// Stop all running timers
  Future<void> stopAllRunningTimers() async {
    await _repository.stopAllRunningTimers();
    await _loadTimers(); // Refresh the cache
  }
  
  /// Clear all timer data
  Future<void> clearAllTimers() async {
    for (final timer in _cachedTimers) {
      await _repository.delete(timer.id);
    }
    _cachedTimers = [];
    notifyListeners();
  }
}