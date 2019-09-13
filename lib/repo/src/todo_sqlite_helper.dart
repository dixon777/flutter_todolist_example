import 'dart:async';

import 'package:example_todolist/global_setting.dart' as gs;
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/util/sqlite_helper.dart';
import 'package:sqflite/sqflite.dart';

class TodolistSQLiteHelper extends SQLiteHelper {
  TodolistSQLiteHelper() : super(gs.todolistDbName, gs.todolistDbVersion);

  @override
  FutureOr<void> onCreate(Database db, int version) async {
    super.onCreate(db, version);
    final batch = db.batch();
    batch.execute("""CREATE TABLE IF NOT EXISTS ${gs.todoTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${Todo.key_due} INTEGER,
         ${Todo.key_title} TEXT NOT NULL, 
         ${Todo.key_complete} INTEGER NOT NULL,
         "${Todo.key_expectedDuration}" INTEGER)""");

    batch.execute("""CREATE TABLE IF NOT EXISTS ${gs.todoLogTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${TodoLog.key_startTime} INTEGER NOT NULL,
         ${TodoLog.key_duration} INTEGER NOT NULL, 
         ${Todo.key_foreign} INTEGER NOT NULL,
         FOREIGN KEY (${Todo.key_foreign}) REFERENCES ${gs.todoTableName} (${BaseModel.key_id}) ON DELETE CASCADE)""");

    batch.execute("""CREATE TABLE IF NOT EXISTS ${gs.todoTrackingTableName} 
        (${BaseModel.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${TodoLog.key_startTime} INTEGER NOT NULL,
         ${TodoLog.key_duration} INTEGER, 
         ${Todo.key_foreign} INTEGER NOT NULL,
         FOREIGN KEY (${Todo.key_foreign}) REFERENCES ${gs.todoTableName} (${BaseModel.key_id}) ON DELETE CASCADE)""");
    await batch.commit();
  }
}