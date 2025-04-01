import 'package:flutter/material.dart';
import '../models/todo_model.dart';

/// Utility class for working with todo priorities
class PriorityUtils {
  /// Get color for priority level
  static Color getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Colors.red;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.low:
        return Colors.green;
    }
  }
  
  /// Get icon for priority level
  static IconData getPriorityIcon(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return Icons.priority_high;
      case TodoPriority.medium:
        return Icons.drag_handle;
      case TodoPriority.low:
        return Icons.low_priority;
    }
  }
  
  /// Get display name for priority level
  static String getPriorityName(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.high:
        return 'High';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.low:
        return 'Low';
    }
  }
}
