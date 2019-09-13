import 'dart:async';
import 'package:example_todolist/settings/settings.dart' as settings;
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/util/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';

class SelfDefinedSQLiteHelper extends SQLiteHelper {
  SelfDefinedSQLiteHelper() : super(settings.todolistDbName, settings.todolistDbVersion);

  @override
  FutureOr<void> onCreate(Database db, int version) async {
    super.onCreate(db, version);
    final batch = db.batch();
    batch.execute("""CREATE TABLE IF NOT EXISTS ${settings.todoTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
         ${Todo.key_due} INTEGER,
         ${Todo.key_title} TEXT NOT NULL, 
         ${Todo.key_complete} INTEGER NOT NULL,
         "${Todo.key_expectedDuration}" INTEGER)""");

    batch.execute("""CREATE TABLE IF NOT EXISTS ${settings.todoLogTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         ${TodoLog.key_startTime} INTEGER NOT NULL,
         ${TodoLog.key_duration} INTEGER NOT NULL, 
         ${Todo.key_foreign} INTEGER NOT NULL,
         FOREIGN KEY (${Todo.key_foreign}) REFERENCES ${settings.todoTableName} (${BaseModel.key_id}) ON DELETE CASCADE)""");

    batch.execute("""CREATE TABLE IF NOT EXISTS ${settings.todoTrackingTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${TodoLog.key_startTime} INTEGER NOT NULL,
         ${TodoLog.key_duration} INTEGER, 
         ${Todo.key_foreign} INTEGER NOT NULL,
         FOREIGN KEY (${Todo.key_foreign}) REFERENCES ${settings.todoTableName} (${BaseModel.key_id}) ON DELETE CASCADE)""");
    await batch.commit();
  }
}