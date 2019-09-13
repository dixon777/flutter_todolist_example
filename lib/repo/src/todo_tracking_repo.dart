// Used to store the running tracking details even if the app is killed by OS
import 'package:example_todolist/global_setting.dart' as gs;
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repo/repo.dart';

class TodoTrackingRepo extends BaseRepo {
  TodoTrackingRepo({helper}):super(helper: helper, tableName: gs.todoTrackingTableName);

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