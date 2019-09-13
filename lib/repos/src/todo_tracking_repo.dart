// Used to store the running tracking details even if the app is killed by OS
import 'package:example_todolist/settings/settings.dart' as settings;
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/repo.dart';

class TodoTrackingRepo extends BaseRepo {
  TodoTrackingRepo({helper}):super(helper: helper, tableName: settings.todoTrackingTableName);

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