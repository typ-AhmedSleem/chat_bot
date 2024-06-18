import 'package:intl/intl.dart' show DateFormat;

const String defaultLocale = "ar";
const String timestampFormatPattern = "dd MMM yyyy hh:mm aa";

String nowFormatted({String pattern = timestampFormatPattern}) {
  return formatTimestamp(DateTime.now())!;
}

DateTime? parseTimestamp(String timestamp) {
  // final timePattern = RegExp(r'\b\d{1,2}:\d{2} (?:ص|م|مساء|صباحا)\b');
  final timePattern = RegExp(r'\b(\d{1,2}:\d{2})(?:\s?(ص|م|مساء|صباحا)?)\b');
  final match = timePattern.firstMatch(timestamp);

  if (match != null) {
    String timeString = (match.group(0) ?? "").trim().toUpperCase();
    if (timeString.isEmpty) return null;

    final now = DateTime.now();
    final splits = timeString.split(":");
    print("Splits are: $splits");

    final int hour = int.parse(splits.first);
    final int minutes = int.parse(splits.last);

    DateTime timestamp = DateTime(now.year, now.month, now.day, hour, minutes);
    while (timestamp.isBefore(now)) {
      // * Add 12 hours fix to flip between am/pm
      timestamp = timestamp.add(const Duration(hours: 12));
    }
    return timestamp;
  }
  return null;
}

String? formatTimestamp(DateTime? dateTime, {String pattern = timestampFormatPattern}) {
  if (dateTime == null) return null;
  return DateFormat(pattern).format(dateTime);
}
