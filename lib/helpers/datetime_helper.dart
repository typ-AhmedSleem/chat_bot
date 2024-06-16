import 'package:intl/intl.dart';

const String defaultLocale = "ar";
const String timestampFormatPattern = "hh:mm aa";

String nowFormatted() {
  return DateFormat(timestampFormatPattern).format(DateTime.now());
}
