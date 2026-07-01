import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String formatDate() {
    return DateFormat('yyyy-MM-dd', 'en').format(this);
  }

  String formatDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm', 'en').format(this);
  }

  String formatTime() {
    return DateFormat('HH:mm', 'en').format(this);
  }
}
