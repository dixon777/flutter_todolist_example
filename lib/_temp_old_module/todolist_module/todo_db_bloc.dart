import 'package:bloc/bloc.dart';

import 'todolist_module.dart';

enum TodoItemEventType {
  add,
  update,
  delete,
  deleteAll,
  deleteDB, //debug
  get,
}

enum TodoRecordEventType { add, update, delete, get }

class TodoEvent<E, T> {
  final E type;
  final List<T> items;

  TodoEvent({this.type, this.items});
}

class TodoItemEvent extends TodoEvent<TodoItemEventType, Todo> {
  TodoItemEvent({type, todos})
      : assert(type != null &&
            (type == TodoItemEventType.get ||
                type == TodoItemEventType.deleteAll ||
                type == TodoItemEventType.deleteDB ||
                todos != null)),
        super(type: type, items: todos);
}

class TodoRecordEvent extends TodoEvent<TodoRecordEventType, TodoRecord> {
  TodoRecordEvent({type, records})
      : assert(type != null &&
            (type == TodoRecordEventType.get || records != null)),
        super(type: type, items: records);
}

class TodoDbState {
  final List<Todo> todos;
  final TodoEvent event;

  TodoDbState({this.event, todos}) : this.todos = todos ?? <Todo>[];
}

class TodoDbBloc extends Bloc<TodoEvent, TodoDbState> {
  TodolistSQLiteHelper _dbHelper = TodolistSQLiteHelper();

  @override
  TodoDbState get initialState => TodoDbState();

  @override
  Stream<TodoDbState> mapEventToState(TodoEvent event) async* {
    if (event.type is TodoItemEventType) {
      switch (event.type) {
        case TodoItemEventType.add:
          await _dbHelper.addTodos(event.items);
          break;
        case TodoItemEventType.update:
          await _dbHelper.updateTodos(event.items);
          break;
        case TodoItemEventType.delete:
          await _dbHelper.deleteTodos(event.items);
          break;
        case TodoItemEventType.deleteAll:
          await _dbHelper.deleteAllTodos();
          break;
        case TodoItemEventType.get:
          break;
        case TodoItemEventType.deleteDB:
          await _dbHelper.deleteDb();
          break;
      }
    } else if(event.type is TodoRecordEventType) {
      switch (event.type) {
        case TodoRecordEventType.add:
          await _dbHelper.addTodoRecords(event.items);
          break;
        case TodoRecordEventType.update:
          await _dbHelper.updateTodoRecords(event.items);
          break;
        case TodoRecordEventType.delete:
          await _dbHelper.deleteTodoRecords(event.items);
          break;
        case TodoRecordEventType.get:
          break;
      }
    }

    yield TodoDbState(event: event, todos: await _dbHelper.getAllTodos());
  }

  @override
  void dispose() async {
    super.dispose();
    await _dbHelper.close();
  }
}
