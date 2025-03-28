import '../../models/timer_model.dart';
import 'base_repository.dart';

/// Repository interface for Timer operations
/// Extends the base repository with Timer-specific operations
abstract class TimerRepository extends BaseRepository<TaskTimer> {
  /// Get all currently running timers
  Future<List<TaskTimer>> getRunningTimers();
  
  /// Toggle a timer's running state
  /// If timer is running, it will be stopped
  /// If timer is stopped, a new timer with the same name will be created
  Future<TaskTimer?> toggleTimer(String id);
  
  /// Stop all running timers
  Future<void> stopAllRunningTimers();
  
  /// Calculate total duration of given timer IDs
  Duration calculateTotalDuration(List<String> timerIds, DateTime currentTime);
}
