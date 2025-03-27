/// Utility class for formatting time-related values
class TimeFormatter {
  /// Formats a duration into HH:MM:SS format
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  /// Formats a DateTime into HH:MM:SS format
  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }

  /// Formats a DateTime into a more human-readable format
  static String formatDateTimeReadable(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final time = formatDateTime(dateTime);
    
    if (dateToCheck == today) {
      return 'Today at $time';
    } else if (dateToCheck == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at $time';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $time';
    }
  }
  
  /// Formats a duration in a human-readable way
  static String formatDurationReadable(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
} 