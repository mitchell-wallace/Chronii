import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_model.dart';

/// Service for managing timers with persistence
class TimerService {
  static const String _storageKey = 'timers';
  List<TaskTimer> _timers = [];
  
  /// Get all timers
  List<TaskTimer> get timers => List.unmodifiable(_timers);
  
  /// Initialize the service and load saved timers
  Future<void> init() async {
    await _loadTimers();
  }
  
  /// Load timers from persistent storage
  Future<void> _loadTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = prefs.getString(_storageKey);
      
      if (timersJson != null) {
        final List<dynamic> decoded = jsonDecode(timersJson);
        _timers = decoded.map((json) => TaskTimer.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error loading timers: $e');
      // If loading fails, we'll start with an empty list
      _timers = [];
    }
  }
  
  /// Save timers to persistent storage
  Future<void> _saveTimers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timersJson = jsonEncode(_timers.map((timer) => timer.toJson()).toList());
      await prefs.setString(_storageKey, timersJson);
    } catch (e) {
      debugPrint('Error saving timers: $e');
    }
  }
  
  /// Add a new timer
  Future<TaskTimer> addTimer(String name) async {
    final timer = TaskTimer(
      name: name.trim(),
      startTime: DateTime.now(),
    );
    
    _timers.add(timer);
    await _saveTimers();
    return timer;
  }
  
  /// Update an existing timer
  Future<bool> updateTimer(TaskTimer updatedTimer) async {
    final index = _timers.indexWhere((timer) => timer.id == updatedTimer.id);
    if (index == -1) return false;
    
    _timers[index] = updatedTimer;
    await _saveTimers();
    return true;
  }
  
  /// Toggle a timer's running state
  /// If timer is running, it will be stopped
  /// If timer is stopped, a new timer with the same name will be created
  Future<TaskTimer?> toggleTimer(String timerId) async {
    final timerIndex = _timers.indexWhere((t) => t.id == timerId);
    if (timerIndex == -1) return null;
    
    final timer = _timers[timerIndex];
    TaskTimer? newTimer;
    
    if (timer.isRunning) {
      // Stop the timer
      timer.stop();
    } else {
      // Create a new timer with same name
      newTimer = timer.createNewSession();
      _timers.add(newTimer);
    }
    
    await _saveTimers();
    return newTimer;
  }
  
  /// Delete a timer
  Future<bool> deleteTimer(String timerId) async {
    final initialLength = _timers.length;
    _timers.removeWhere((timer) => timer.id == timerId);
    
    if (_timers.length != initialLength) {
      await _saveTimers();
      return true;
    }
    return false;
  }
  
  /// Calculate total duration of given timer IDs
  Duration calculateTotalDuration(List<String> timerIds) {
    final now = DateTime.now();
    return _timers
        .where((timer) => timerIds.contains(timer.id))
        .fold(Duration.zero, (total, timer) => total + timer.getDuration(now));
  }
  
  /// Get all currently running timers
  List<TaskTimer> getRunningTimers() {
    return _timers.where((timer) => timer.isRunning).toList();
  }
  
  /// Stop all running timers
  Future<void> stopAllRunningTimers() async {
    bool changes = false;
    
    for (final timer in _timers) {
      if (timer.isRunning) {
        timer.stop();
        changes = true;
      }
    }
    
    if (changes) {
      await _saveTimers();
    }
  }
  
  /// Clear all timer data
  Future<void> clearAllTimers() async {
    _timers.clear();
    await _saveTimers();
  }
} 