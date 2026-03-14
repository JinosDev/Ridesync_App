import 'package:intl/intl.dart';

/// Date and time formatting utilities
class DateFormatter {
  DateFormatter._();

  static final _dateFormat     = DateFormat('dd MMM yyyy');
  static final _timeFormat     = DateFormat('hh:mm a');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _apiDateFormat  = DateFormat('yyyy-MM-dd');

  static String formatDate(DateTime dt)     => _dateFormat.format(dt);
  static String formatTime(DateTime dt)     => _timeFormat.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);
  static String toApiDate(DateTime dt)      => _apiDateFormat.format(dt);

  /// Format epoch milliseconds as hh:mm a
  static String formatEtaMs(int epochMs) {
    return _timeFormat.format(DateTime.fromMillisecondsSinceEpoch(epochMs));
  }

  /// Human-readable delay string
  static String formatDelay(int minutes) {
    if (minutes == 0) return 'On time';
    return '$minutes min${minutes == 1 ? '' : 's'} late';
  }
}
