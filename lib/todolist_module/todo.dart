import 'dart:async';

import 'package:example_todolist/util/util.dart';
import 'package:example_todolist/global_setting.dart' as gs;
import 'package:sqflite/sqflite.dart';

class Todo extends Item {
  static const key_id = Item.key_id;
  static const key_title = 'name';
  static const key_hasComplete = 'complete';
  static const key_due = 'due';
  static const key_expectedDuration = 'expected_duration';
  static const key_records = 'records';

  static const key_foreign = 'todo_id';

  String title;
  bool hasCompleted;
  DateTime due;
  Duration expectedDuration;
  List<TodoRecord> records;

  Duration get totalDuration => records.isEmpty
        ? Duration(seconds: 0)
        : records.map((r) => r.duration).reduce((val, d) => val + d);

  Todo({id, title, due, hasCompleted, expectedDuration, records})
      : this.title = title ?? "",
        this.due = due ?? DateTime.now(),
        this.hasCompleted = hasCompleted is int ? hasCompleted > 0: hasCompleted is bool ? hasCompleted: false,
        this.expectedDuration = expectedDuration ?? null,
        this.records = records ?? [],
        super(id: id);

  static Todo fromMap(Map<String, dynamic> map) {
    final due = map[key_due] != null
        ? DateTime.fromMillisecondsSinceEpoch(map[key_due])
        : null;
    final expectedDuration = map[key_expectedDuration] != null
        ? Duration(seconds: map[key_expectedDuration])
        : null;
    return Todo(
        id: map[Item.key_id],
        title: map[key_title],
        hasCompleted: map[key_hasComplete],
        due: due,
        expectedDuration: expectedDuration,
        records: map[key_records]
            ?.map<TodoRecord>((recordMap) => TodoRecord.fromMap(recordMap))
            ?.toList());
  }

  @override
  Map<String, dynamic> toMap({withId: true, withRecords: false}) {
    final Map<String, dynamic> jsonMap = super.toMap(withId: withId);
    jsonMap.addAll(<String, dynamic>{
      key_title: title,
      key_due: due?.millisecondsSinceEpoch,
      key_hasComplete: hasCompleted ? 1 : 0,
      key_expectedDuration: expectedDuration?.inSeconds,
    });
    
    if (withRecords) {
      jsonMap[key_records] =
          records.map<Map>((record) => record.toMap(withId: true)).toList();
    }
    return jsonMap;
  }
}

class TodoRecord extends Item {
  static const key_startTime = 'start_time';
  static const key_duration = 'duration';

  int id;
  int todoId;
  DateTime startTime;
  Duration duration;

  TodoRecord({id, this.todoId, startTime, duration}): 
  this.startTime = startTime is int ? DateTime.fromMillisecondsSinceEpoch(startTime): startTime,
  this.duration = duration is int ? Duration(seconds: duration): duration,
  super(id:id);

  static TodoRecord fromMap(Map<String, dynamic> map) {
    return TodoRecord(
        id: map[Item.key_id],
        todoId: map[Todo.key_foreign],
        startTime: map[key_startTime],
        duration: map[key_duration]);
  }

  Map<String, dynamic> toMap({withId: true}) {
    var jsonMap = super.toMap(withId: withId);
    jsonMap.addAll(<String, dynamic>{
      Todo.key_foreign: todoId,
      key_startTime: startTime.millisecondsSinceEpoch,
      key_duration: duration.inSeconds,
    });
    return jsonMap;
  }
}

// class TodolistTableHelper extends SQLiteTableHelper<TodolistSQLiteHelper> {
//   TodolistTableHelper(String global_setting.todolistTableName, SQLiteDBHelper dbHelper) : super(global_setting.todolistTableName, dbHelper);

//   @override
//   void onCreateTable(TodolistSQLiteHelper dbHelper, int version) {
//   }

// }

class TodolistSQLiteHelper extends SQLiteDBHelper {
  TodolistSQLiteHelper() : super(gs.todolistDbName, gs.todolistDbVersion);

  @override
  FutureOr<void> onCreate(Database db, int version) async {
    super.onCreate(db, version);
    final batch = db.batch();
    batch.execute("""CREATE TABLE IF NOT EXISTS ${gs.todoTableName} 
        (${Item.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${Todo.key_due} INTEGER,
         ${Todo.key_title} TEXT NOT NULL, 
         ${Todo.key_hasComplete} INTEGER NOT NULL,
         "${Todo.key_expectedDuration}" INTEGER)""");
    batch.execute("""CREATE TABLE IF NOT EXISTS ${gs.todoRecordTableName} 
        (${Item.key_id} INTEGER PRIMARY KEY AUTOINCREMENT, 
         ${TodoRecord.key_startTime} INTEGER NOT NULL,
         ${TodoRecord.key_duration} INTEGER NOT NULL, 
         ${Todo.key_foreign} INTEGER NOT NULL,
         FOREIGN KEY (${Todo.key_foreign}) REFERENCES ${gs.todoTableName} (${Item.key_id}) ON DELETE CASCADE)""");
    await batch.commit();
  }

  Future<List<Todo>> getAllTodos() async {
    try {
      final db = await database;

      final todos = (await db.query(
        gs.todoTableName,
      ))
          .map<Todo>((Map<String, dynamic> jsonMap) => Todo.fromMap(jsonMap))
          .toList();
      final results = await performBatch((batch) {
        todos.forEach((Todo todo) {
          batch.query(gs.todoRecordTableName,
              where: "${Todo.key_foreign}=?", whereArgs: [todo.id]);
        });
        batch.query(gs.todoRecordTableName);
        return batch;
      });
      for (int i = 0; i < todos.length; ++i) {
        results[i]
            .map<TodoRecord>((Map<String, dynamic> jsonMap) => TodoRecord.fromMap(jsonMap))
            .forEach((record) {
          todos[i].records.add(record);
        });
      }
      
      return todos;
    } catch (err) {
      print(err);
    }
    return [];
  }

  FutureOr<List<int>> addTodos(List<Todo> newTodos) async {
    try {
      newTodos.forEach((t) {
        print(t.toMap());
      });
      final results = await performBatch((batch) {
        newTodos.forEach((todo) {
          batch.insert(gs.todoTableName, todo.toMap(),
              conflictAlgorithm: ConflictAlgorithm.abort);
        });
        return batch;
      });
      print(results);
      return results.map<int>((v) => v).toList();
    } catch (err) {
      print(err);
    }
    return [];
  }

  FutureOr<List<int>> updateTodos(List<Todo> todos) async {
    final results = await performBatch((batch) {
      todos.forEach((todo) {
        batch.update(gs.todoTableName, todo.toMap(withId: false),
            where: "${Todo.key_id} = ?", whereArgs: [todo.id]);
      });
      return batch;
    });
    return results.map<int>((v) => v).toList();
  }

  FutureOr<List<int>> deleteTodos(List<Todo> todos) async {
    final results = await performBatch((batch) {
      todos.forEach((todo) {
        batch.delete(gs.todoTableName,
            where: "${Todo.key_id} = ?", whereArgs: [todo.id]);
      });
      return batch;
    });

    return results.map<int>((v) => v).toList();
  }

  FutureOr<int> deleteAllTodos() async {
    final db = (await database);
    if (db == null) return 0;

    return (await database)?.delete(gs.todoTableName, where: "1");
  }

  FutureOr<List<int>> addTodoRecords(List<TodoRecord> records) async {
    try {
      final results = await performBatch((batch) {
        records.forEach((record) {
          batch.insert(gs.todoRecordTableName, record.toMap());
        });
        return batch;
      });
      return results.map<int>((v) => v).toList();
    } catch (err) {
      print(err);
    }
    return [];
  }

  FutureOr<List<int>> updateTodoRecords(List<TodoRecord> records) async {
    try {
      final results = await performBatch((batch) {
        records.forEach((record) {
          batch.update(gs.todoRecordTableName, record.toMap(),
              where: "${Item.key_id} = ?",
              whereArgs: [
                record.id,
              ]);
        });
        return batch;
      });
      return results.map<int>((v) => v).toList();
    } catch (err) {
      print(err);
    }
    return [];
  }

  FutureOr<List<int>> deleteTodoRecords(List<TodoRecord> records) async {
    try {
      final results = await performBatch((batch) {
        records.forEach((record) {
          batch.delete(gs.todoRecordTableName,
              where: "${Item.key_id} = ?",
              whereArgs: [
                record.id,
              ]);
        });
        return batch;
      });
      return results.map<int>((v) => v).toList();
    } catch (err) {
      print(err);
    }
    return [];
  }
}
