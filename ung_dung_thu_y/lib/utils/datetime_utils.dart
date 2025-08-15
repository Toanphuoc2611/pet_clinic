import 'package:intl/intl.dart';

/// Extension methods for DateTime
extension DateTimeExtension on DateTime {
  /// Format DateTime to display format
  String formatDateTime() {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Format DateTime to date only
  String formatDateOnly() {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Format DateTime to time only
  String formatTimeOnly() {
    return DateFormat('HH:mm').format(this);
  }
}

class DateTimeUtils {
  /// Format datetime string from server to display format
  /// Handles timezone conversion automatically
  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return "Chưa cập nhật";
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString.isEmpty ? "Chưa cập nhật" : dateTimeString;
    }
  }

  /// Format date only (without time)
  static String formatDateOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return "Chưa cập nhật";
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateTimeString.isEmpty ? "Chưa cập nhật" : dateTimeString;
    }
  }

  /// Format time only (without date)
  static String formatTimeOnly(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return "Chưa cập nhật";
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString.isEmpty ? "Chưa cập nhật" : dateTimeString;
    }
  }

  /// Parse datetime string safely
  static DateTime? parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      // Convert to local timezone if the parsed datetime is in UTC
      if (dateTime.isUtc) {
        dateTime = dateTime.toLocal();
      }
      return dateTime;
    } catch (e) {
      return null;
    }
  }

  /// Check if a datetime string represents today
  static bool isToday(String? dateTimeString) {
    final dateTime = parseDateTime(dateTimeString);
    if (dateTime == null) return false;

    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Get time difference between two datetime strings
  static Duration? getTimeDifference(String? startTime, String? endTime) {
    final start = parseDateTime(startTime);
    final end = parseDateTime(endTime);

    if (start == null || end == null) return null;
    return end.difference(start);
  }

  /// Calculate days between two datetime strings
  static int calculateDays(String? startTime, String? endTime) {
    final difference = getTimeDifference(startTime, endTime);
    if (difference == null) return 0;
    return difference.inDays;
  }
}
