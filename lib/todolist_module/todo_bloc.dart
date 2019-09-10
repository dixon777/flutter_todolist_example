import 'package:bloc/bloc.dart';

import 'todolist_module.dart';

enum TodoEventType {
  add,
  update,
  delete,
  deleteAll,
  deleteDB, //debug
  get,
}

class TodoEvent {
  final TodoEventType eventType;
  final List<Todo> todos;

  

  TodoEvent(this.eventType, {this.todos})
      : assert(eventType == TodoEventType.get ||
            eventType == TodoEventType.deleteAll ||
            eventType == TodoEventType.deleteDB ||
            todos != null);
}

class TodoState {
  final List<Todo> todos;

  TodoState({todos}) : this.todos = todos ?? <Todo>[];
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodolistSQLiteHelper dbHelper = TodolistSQLiteHelper();

  @override
  TodoState get initialState => TodoState();

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    switch (event.eventType) {
      case TodoEventType.add:
        await dbHelper.addTodos(event.todos);
        break;
      case TodoEventType.update:
        await dbHelper.updateTodos(event.todos);
        break;
      case TodoEventType.delete:
        await dbHelper.deleteTodos(event.todos);
        break;
      case TodoEventType.deleteAll:
        await dbHelper.deleteAll();
        break;
      case TodoEventType.get:
        break;
      case TodoEventType.deleteDB:
        await dbHelper.deleteDb();
        break;
    }

    yield TodoState(todos: await dbHelper.getAllTodos());
  }
}
