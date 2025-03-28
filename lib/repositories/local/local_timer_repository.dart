import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/timer_model.dart';
import '../base/timer_repository.dart';

/// Implementation of TimerRepository that uses SharedPreferences for local storage
class LocalTimerRepository implements TimerRepository {
  static const String _storageKey = 'timers';
  List<TaskTimer> _timers = [];
  
  @override
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
  
  @override
  Future<List<TaskTimer>> getAll() async {
    return List.unmodifiable(_timers);
  }
  
  @override
  Future<TaskTimer?> getById(String id) async {
    try {
      return _timers.firstWhere((timer) => timer.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<TaskTimer> add(TaskTimer timer) async {
    _timers.add(timer);
    await _saveTimers();
    return timer;
  }
  
  @override
  Future<bool> update(TaskTimer updatedTimer) async {
    final index = _timers.indexWhere((timer) => timer.id == updatedTimer.id);
    if (index == -1) return false;
    
    _timers[index] = updatedTimer;
    await _saveTimers();
    return true;
  }
  
  @override
  Future<bool> delete(String id) async {
    final initialLength = _timers.length;
    _timers.removeWhere((timer) => timer.id == id);
    
    if (_timers.length != initialLength) {
      await _saveTimers();
      return true;
    }
    return false;
  }
  
  @override
  Future<List<TaskTimer>> getRunningTimers() async {
    return _timers.where((timer) => timer.isRunning).toList();
  }
  
  @override
  Future<TaskTimer?> toggleTimer(String id) async {
    final timerIndex = _timers.indexWhere((t) => t.id == id);
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
    return newTimer ?? timer;
  }
  
  @override
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
  
  @override
  Duration calculateTotalDuration(List<String> timerIds, DateTime currentTime) {
    return _timers
        .where((timer) => timerIds.contains(timer.id))
        .fold(Duration.zero, (total, timer) => total + timer.getDuration(currentTime));
  }
}
