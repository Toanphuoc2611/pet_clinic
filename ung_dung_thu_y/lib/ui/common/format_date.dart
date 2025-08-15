import 'package:intl/intl.dart';

class FormatDate {
  static String formatDatePicker(DateTime? date) {
    if (date == null) {
      return "";
    }
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  static String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return "";
    }
    final updatedAt = DateTime.parse(date);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(updatedAt.day)}/${twoDigits(updatedAt.month)}/${updatedAt.year}";
  }

  // format date from dd/MM/yyyy to yyyy-MM-dd to send to backend
  static String formatRequest(String date) {
    final parts = date.split('/');
    if (parts.length != 3) return "";
    final day = parts[0];
    final month = parts[1];
    final year = parts[2];
    return "$year-$month-$day";
  }

  static String formatAppointmentDateTime(String isoString) {
    final dateTime =
        DateTime.parse(isoString).toLocal(); // Change to local time

    final weekday = DateFormat.EEEE('vi').format(dateTime); // format to Thứ
    final date = DateFormat(
      'dd/MM/yyyy',
    ).format(dateTime); // format to dd/MM/yyyy
    final timeStart = DateFormat('HH:mm').format(dateTime); // Time start

    return '$date $timeStart';
  }
}
