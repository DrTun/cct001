import 'package:intl/intl.dart';

String xpassFormatDateTime(String passingTime) {
  DateTime dateTime = DateTime.parse(passingTime);
  return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
}
