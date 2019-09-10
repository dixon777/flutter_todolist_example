import 'dart:async';
import 'dart:convert';

import 'package:example_todolist/util/util.dart';
import 'package:example_todolist/global_setting.dart' as global_setting;
import 'package:sqflite/sqflite.dart';

class Todo {
  static const key_id = 'id';
  static const key_name = 'name';
  static const key_hasComplete = 'complete';
  static const key_due = 'due';

  int id;
  String name;
  bool hasCompleted;
  DateTime due;

  Todo({this.name, this.due, this.hasCompleted: false});

  Todo.fromMap(Map<String, dynamic> map) {
    id = map[key_id];
    name = map[key_name];
    hasCompleted = map[key_hasComplete] == 1;
    if(map.containsKey(key_due))
      due = DateTime.fromMillisecondsSinceEpoch(map[key_due]);
  }

  Map<String, dynamic> toMap({withId: true}) {
    var jsonMap = <String, dynamic>{};
    if (withId && id != null) {
      jsonMap[key_id] = key_id;
    }
    if (due != null) {
      jsonMap[key_due] = due.millisecondsSinceEpoch;
    }

    jsonMap.addAll(<String, dynamic>{
      key_name: name,
      key_hasComplete: hasCompleted ? 1 : 0,
    });
    return jsonMap;

    @override
    String toString() {
      super.toString();
      return json.encode(toMap());
    }
  }
}

// class TodolistTableHelper extends SQLiteTableHelper<TodolistSQLiteHelper> {
//   TodolistTableHelper(String tableName, SQLiteDBHelper dbHelper) : super(tableName, dbHelper);

//   @override
//   void onCreateTable(TodolistSQLiteHelper dbHelper, int version) {
//   }

// }

class TodolistSQLiteHelper extends SQLiteDBHelper {
  final tableName = global_setting.todolistTableName;
  TodolistSQLiteHelper()
      : super(global_setting.todolistDbName, global_setting.todolistDbVersion);

  @override
  FutureOr<void> onCreate(Database db, int version) async {
    super.onCreate(db, version);
    await db.execute(
        """CREATE TABLE ${global_setting.todolistTableName} (${Todo.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
        ${Todo.key_due} INTEGER,
         ${Todo.key_name} TEXT NOT NULL, 
         ${Todo.key_hasComplete} INTEGER NOT NULL)""");
  }

  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    return (await db.query(
      tableName,
    ))
        .map((Map<String, dynamic> jsonMap) => Todo.fromMap(jsonMap))
        .toList();
  }

  FutureOr<List<int>> addTodos(List<Todo> newTodos) async {
    print("B");
    final results = await performBatch((batch) {
      newTodos.forEach((todo) {
        batch.insert(tableName, todo.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort);
      });
      return batch;
    });
    print("A");
    return results.map<int>((v) => v).toList();
  }

  FutureOr<List<int>> updateTodos(List<Todo> todos) async {
    final results = await performBatch((batch) {
      todos.forEach((todo) {
        batch.update(tableName, todo.toMap(withId: false),
            where: "${Todo.key_id} = ?", whereArgs: [todo.id]);
      });
      return batch;
    });
    return results.map<int>((v) => v).toList();
  }

  FutureOr<List<int>> deleteTodos(List<Todo> todos) async {
    final results = await performBatch((batch) {
      todos.forEach((todo) {
        batch.delete(tableName,
            where: "${Todo.key_id} = ?", whereArgs: [todo.id]);
      });
      return batch;
    });

    return results.map<int>((v) => v).toList();
  }

  FutureOr<int> deleteAll() async {
    final db = (await database);
    if (db == null) return 0;

    return (await database)?.delete(tableName, where: "1");
  }
}
