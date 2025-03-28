import 'package:flutter/material.dart';
import '../models/timer_model.dart';
import 'time_formatter.dart';

/// Utility class for grouping timers and calculating summaries
class TimerGroupingUtil {
  /// Groups timers by day and calculates total duration for each group
  /// Returns a map with date as key (normalized to midnight) and a TimerGroup as value
  static Map<DateTime, TimerGroup> groupByDay(List<TaskTimer> timers) {
    final Map<DateTime, List<TaskTimer>> groupedTimers = {};
    final Map<DateTime, Duration> groupDurations = {};
    final now = DateTime.now();
    
    // First pass: group timers by day
    for (final timer in timers) {
      // Normalize date to midnight to ensure proper grouping
      final date = DateTime(
        timer.startTime.year,
        timer.startTime.month,
        timer.startTime.day,
      );
      
      if (!groupedTimers.containsKey(date)) {
        groupedTimers[date] = [];
        groupDurations[date] = Duration.zero;
      }
      
      groupedTimers[date]!.add(timer);
      groupDurations[date] = groupDurations[date]! + timer.getDuration(now);
    }
    
    // Create TimerGroup objects for each day
    final Map<DateTime, TimerGroup> result = {};
    for (final date in groupedTimers.keys) {
      // Sort timers within each group (most recent first)
      groupedTimers[date]!.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      result[date] = TimerGroup(
        groupKey: date,
        timers: groupedTimers[date]!,
        totalDuration: groupDurations[date]!,
        title: _formatDayTitle(date),
      );
    }
    
    return result;
  }
  
  /// Groups timers by week and calculates total duration for each group
  /// Returns a map with the first day of the week as key and a TimerGroup as value
  static Map<DateTime, TimerGroup> groupByWeek(List<TaskTimer> timers) {
    final Map<DateTime, List<TaskTimer>> groupedTimers = {};
    final Map<DateTime, Duration> groupDurations = {};
    final now = DateTime.now();
    
    // First pass: group timers by week
    for (final timer in timers) {
      // Find the first day of the week (weeks start on Sunday)
      final date = getStartOfWeek(timer.startTime);
      
      if (!groupedTimers.containsKey(date)) {
        groupedTimers[date] = [];
        groupDurations[date] = Duration.zero;
      }
      
      groupedTimers[date]!.add(timer);
      groupDurations[date] = groupDurations[date]! + timer.getDuration(now);
    }
    
    // Create TimerGroup objects for each week
    final Map<DateTime, TimerGroup> result = {};
    for (final weekStart in groupedTimers.keys) {
      // Sort timers within each group (most recent first)
      groupedTimers[weekStart]!.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      // Calculate the end of the week (6 days after start)
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      result[weekStart] = TimerGroup(
        groupKey: weekStart,
        timers: groupedTimers[weekStart]!,
        totalDuration: groupDurations[weekStart]!,
        title: _formatWeekTitle(weekStart, weekEnd),
      );
    }
    
    return result;
  }
  
  /// Gets the start of the week (Sunday) for a given date
  static DateTime getStartOfWeek(DateTime date) {
    // Get the weekday (1 = Monday, 7 = Sunday in Dart)
    // For Sunday as the first day of the week, we need to adjust:
    // Sunday (7) -> 0, Monday (1) -> 1, ..., Saturday (6) -> 6
    final weekday = date.weekday % 7;
    
    // Subtract days to get to Sunday
    final daysToSubtract = weekday;
    
    // Get the date of Sunday that week
    final sundayDate = date.subtract(Duration(days: daysToSubtract));
    
    // Normalize to midnight
    return DateTime(sundayDate.year, sundayDate.month, sundayDate.day);
  }
  
  /// Formats a day title in a readable way (e.g., "Today", "Yesterday", or "Monday, Jan 15")
  static String _formatDayTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (date == today) {
      return 'Today';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (date.isAfter(today.subtract(const Duration(days: 7)))) {
      // Within the last week, show the day name
      return _getDayName(date.weekday) + ', ' + _formatMonthDay(date);
    } else {
      // More than a week ago, show the full date
      return _getDayName(date.weekday) + ', ' + _formatMonthDay(date);
    }
  }
  
  /// Formats a week title range (e.g., "This Week" or "Jan 15 - Jan 21, 2023")
  static String _formatWeekTitle(DateTime weekStart, DateTime weekEnd) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = getStartOfWeek(today);
    
    if (weekStart == thisWeekStart) {
      return 'This Week';
    } else if (weekStart == thisWeekStart.subtract(const Duration(days: 7))) {
      return 'Last Week';
    } else {
      // Format as date range
      return '${_formatMonthDay(weekStart)} - ${_formatMonthDay(weekEnd)}${_shouldIncludeYear(weekStart) ? ', ${weekStart.year}' : ''}';
    }
  }
  
  /// Formats a date as "Jan 15"
  static String _formatMonthDay(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}';
  }
  
  /// Gets the name of a month
  static String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
  
  /// Gets the name of a day
  static String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }
  
  /// Determines if the year should be included in the date format
  static bool _shouldIncludeYear(DateTime date) {
    final now = DateTime.now();
    return date.year != now.year;
  }
  
  /// Sorts a list of date keys in reverse chronological order (newest first)
  static List<DateTime> sortGroupKeys(List<DateTime> keys) {
    keys.sort((a, b) => b.compareTo(a));
    return keys;
  }
  
  /// Groups day dates by their week start date
  static Map<DateTime, List<DateTime>> groupDaysByWeek(List<DateTime> dayDates) {
    final result = <DateTime, List<DateTime>>{};
    
    for (final day in dayDates) {
      final weekStart = getStartOfWeek(day);
      
      if (!result.containsKey(weekStart)) {
        result[weekStart] = [];
      }
      
      result[weekStart]!.add(day);
    }
    
    // Sort the days within each week (newest first)
    for (final key in result.keys) {
      result[key]!.sort((a, b) => b.compareTo(a));
    }
    
    return result;
  }
}

/// Class representing a group of timers with metadata
class TimerGroup {
  /// The key for this group (typically a DateTime representing the day or week)
  final DateTime groupKey;
  
  /// The list of timers in this group
  final List<TaskTimer> timers;
  
  /// The total duration of all timers in this group
  final Duration totalDuration;
  
  /// A formatted title for the group (e.g., "Today" or "Jan 15 - Jan 21")
  final String title;
  
  /// Constructor
  const TimerGroup({
    required this.groupKey,
    required this.timers,
    required this.totalDuration,
    required this.title,
  });
  
  /// Gets the number of timers in this group
  int get count => timers.length;
  
  /// Calculates the total duration for selected timers in this group
  Duration calculateSelectedDuration(Set<String> selectedIds, DateTime now) {
    return timers
        .where((timer) => selectedIds.contains(timer.id))
        .fold(Duration.zero, (total, timer) => total + timer.getDuration(now));
  }
} 