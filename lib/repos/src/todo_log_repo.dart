import 'package:example_todolist/models/src/todo_log_model.dart';
import 'package:example_todolist/settings/settings.dart';

import '../repo.dart';

class TodoLogRepo extends BaseRepo {
  TodoLogRepo({helper}) : super(helper: helper, tableName: todoLogTableName);

  Future<List<TodoLog>> loadTodoLogs() async {
    return loadItems().then((items) => items.map<TodoLog>(TodoLog.fromMap).toList());
  }

  Future<void> addTodoLogs(Iterable<TodoLog> logs) async {
    return addItems(logs.map((log) => log.toMap(withId: false)));
  }

  Future<void> updateTodoLogs(Iterable<TodoLog> logs) async {
    return updateItems(logs.map((log) => log.toMap(withId: true)));
  }

  Future<void> deleteTodoLogs(Iterable<TodoLog> logs) async {
    return deleteItemsOfPrimaryKeys(logs.map((log) => log.id));
  }
}
