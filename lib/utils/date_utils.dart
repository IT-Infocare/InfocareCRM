import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime? date, {String format = 'MMM dd, yyyy'}) {
    if (date == null) return '-';
    return DateFormat(format).format(date);
  }

  static String formatDateTime(DateTime? date, {String format = 'MMM dd, yyyy hh:mm a'}) {
    if (date == null) return '-';
    return DateFormat(format).format(date);
  }

  static String calculateAge(DateTime? createdAt) {
    if (createdAt == null) return '0d';
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    }
    return 'Just now';
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate);
  }

  static String toLocalIsoString([DateTime? date]) {
    final d = (date ?? DateTime.now()).toLocal();
    final offset = d.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final year = d.year.toString().padLeft(4, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    final second = d.second.toString().padLeft(2, '0');
    return '$year-$month-${day}T$hour:$minute:$second$sign$hours:$minutes';
  }
}
