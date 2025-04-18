import 'package:flutter/foundation.dart';

/// Model representing a task timer with start and end times
class TaskTimer {
  /// Unique identifier for the timer
  final String id;
  
  /// Name of the task being timed
  final String name;
  
  /// When the timer was started
  final DateTime startTime;
  
  /// When the timer was stopped (null if still running)
  DateTime? endTime;
  
  /// When the timer record was created
  final DateTime createdAt;

  /// When the timer record was last updated
  DateTime updatedAt;

  /// Constructor for creating a new timer
  TaskTimer({
    required this.name,
    required this.startTime,
    this.endTime,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  /// Checks if the timer is currently running
  bool get isRunning => endTime == null;

  /// Gets the duration of the timer
  Duration getDuration(DateTime currentTime) {
    final end = endTime ?? currentTime;
    return end.difference(startTime);
  }

  /// Stops the timer if it's running
  void stop() {
    if (isRunning) {
      endTime = DateTime.now();
      updatedAt = endTime!; // Update timestamp when stopped
    }
  }

  /// Creates a new timer with the same name but starting now
  TaskTimer createNewSession() {
    return TaskTimer(
      name: name,
      startTime: DateTime.now(),
    );
  }

  /// Converts timer to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  /// Creates a timer from JSON data
  factory TaskTimer.fromJson(Map<String, dynamic> json) {
    try {
      return TaskTimer(
        id: json['id'] as String,
        name: json['name'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
        // Handle missing timestamps for backward compatibility
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.parse(json['startTime'] as String), // Fallback to startTime
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(), // Fallback to now if missing
      );
    } catch (e) {
      debugPrint('Error parsing timer from JSON: $e');
      // Return a fallback timer if parsing fails
      return TaskTimer(
        name: 'Error Timer',
        startTime: DateTime.now(),
      );
    }
  }

  /// Creates a copy of this timer with optional new values
  TaskTimer copyWith({
    String? name,
    DateTime? startTime,
    DateTime? Function()? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskTimer(
      id: id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime != null ? endTime() : this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TaskTimer(id: $id, name: $name, running: $isRunning)';
} 