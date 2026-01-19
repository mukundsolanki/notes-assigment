import 'package:intl/intl.dart';

class DateHelper {
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static TaskGroup getTaskGroup(DateTime dueDate) {
    if (isToday(dueDate)) {
      return TaskGroup.today;
    } else if (isTomorrow(dueDate)) {
      return TaskGroup.tomorrow;
    } else if (isThisWeek(dueDate)) {
      return TaskGroup.thisWeek;
    } else {
      return TaskGroup.later;
    }
  }
}

enum TaskGroup { today, tomorrow, thisWeek, later }

extension TaskGroupExtension on TaskGroup {
  String get title {
    switch (this) {
      case TaskGroup.today:
        return 'Today';
      case TaskGroup.tomorrow:
        return 'Tomorrow';
      case TaskGroup.thisWeek:
        return 'This week';
      case TaskGroup.later:
        return 'Later';
    }
  }
}
