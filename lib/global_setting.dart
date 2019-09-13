import 'package:intl/intl.dart';

const String todolistDbName = "example_todolist.db";
const int todolistDbVersion = 1;
const String todoTableName = "todos";
const String todoLogTableName = "todo_logs";
const String todoTrackingTableName = "todo_trackings";

const String dateFormat = "dd/MM/yyyy";
const String timeFormat = "kk:mm";
const String dateTimeFormat = dateFormat + " " + timeFormat;



String formatDateTime(DateTime dateTime, {String nullReplacement: "Not set"}) {
  if (dateTime == null) return nullReplacement;
  return DateFormat(dateTimeFormat).format(dateTime);
}

String formatDuration(Duration duration, {String nullReplacement: "Not set"}) {
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

// DEBUG
// Display sqflite library log
const bool debugDB = true;
// true: Delete DB (For creating new one without migration), false: Delete all items
const bool deleteDB = false;
