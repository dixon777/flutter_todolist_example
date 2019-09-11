const String todolistDbName = "example_todolist.db";
const int todolistDbVersion = 1;
const String todoTableName = "todos";
const String todoRecordTableName = "todo_records";


const String dateFormat = "dd/MM/yyyy";
const String timeFormat = "kk:mm";
const String dateTimeFormat = dateFormat + " " + timeFormat;

String formatDuration(Duration duration, {String nullReplacement: "Not set"}) {
  if(duration == null) return nullReplacement;
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  final seconds = duration.inSeconds % 60;
  return duration.inMinutes > 0 ? (hours > 0 ? ("${hours}h "): "") + "${minutes}m ": "${seconds}s";
}

// debug
const bool debugDB = true; // Display sqflite library log
const bool deleteDB = true; // true: Delete DB (For creating new one without migration), false: Delete all items


