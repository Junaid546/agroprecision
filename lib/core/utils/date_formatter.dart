import 'package:intl/intl.dart';

class DateFormatter {
  static String toDisplayDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String toDayMonth(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String toFullDate(DateTime date) {
    return DateFormat('EEEE, MMM dd').format(date);
  }

  static String toRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 7) {
      return toDisplayDate(date);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  static String toBatchDay(DateTime startDate) {
    final diff = daysSince(startDate);
    return 'Day $diff';
  }

  static int daysSince(DateTime startDate) {
    return DateTime.now().difference(startDate).inDays + 1;
  }

  static String toDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('MMM dd').format(start);
    final endStr = DateFormat('MMM dd').format(end);
    return '$startStr – $endStr';
  }
}
