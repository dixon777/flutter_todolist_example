import 'package:intl/intl.dart';
import 'package:example_todolist/settings/settings.dart';




String formatDateTime(DateTime dateTime, {String nullReplacement: normalNullReplacement}) {
  if (dateTime == null) return nullReplacement;
  return DateFormat(dateTimeFormat).format(dateTime);
}

String formatDuration(Duration duration, {String nullReplacement: normalNullReplacement}) {
  if (duration == null) return nullReplacement;
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  // if (duration.inMinutes < 1) {
  //   return "${seconds}s";
  // } else if (hours < 1) {
  //   return "${minutes}m ${seconds}s";
  // }
  // return "${hours}h ${minutes}m";
  return  (duration.inHours >= 1 ? "${hours}h ": "") + (duration.inMinutes >= 1 ? "${minutes}m ": "") + "${seconds}s";
}
