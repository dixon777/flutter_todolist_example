import 'package:example_todolist/settings/settings.dart';
import 'package:example_todolist/models/src/todo_model.dart';
import 'base_repo.dart';

class TodoRepo extends BaseRepo {
  TodoRepo({helper}): super(helper:helper, tableName:todoTableName);

  Future<void> deleteDB() async {
    helper.deleteDb();
  }
 
  Future<List<Todo>> loadTodos() async {
    return loadItems().then<List<Todo>>((items) => items.map<Todo>(Todo.fromMap).toList());
  }

  Future<void> addTodos(Iterable<Todo> todos) async {
    return addItems(todos.map((todo)=>todo.toMap(withId: false)));
  }

  Future<void> updateTodos(Iterable<Todo> todos) async {
    return updateItems(todos.map((todo)=>todo.toMap(withId: true)));
  }

  Future<void> deleteTodos(Iterable<Todo> todos) async {
    return deleteItemsOfPrimaryKeys(todos.map((todo)=> todo.id));
  }

}