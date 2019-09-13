import 'package:bloc/bloc.dart';
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:flutter/foundation.dart';

import '../todo_bloc.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepo repo;

  TodoBloc({@required this.repo});

  @override
  TodoState get initialState => TodosNotLoaded();

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    if (event is LoadTodos) {
      yield* _mapLoadTodos(event);
    } else if (event is AddTodo) {
      yield* _mapAddTodo(event);
    } else if (event is UpdateTodo) {
      yield* _mapUpdateTodo(event);
    } else if (event is DeleteTodo) {
      yield* _mapDeleteTodo(event);
    } else if (event is DeleteAllTodos) {
      yield* _mapDeleteAllTodos(event);
    } else if (event is DeleteDB) {
      yield* _mapDeleteDB(event);
    }
  }

  Stream<TodoState> _mapLoadTodos(LoadTodos event) async* {
    yield TodosLoading();
    try {
      final todos = await this.repo.loadTodos();

      yield TodosLoaded(todos: todos, event: event);
    } catch (err) {
      print(err);
      yield TodosNotLoaded();
    }
  }

  Stream<TodoState> _mapAddTodo(AddTodo event) async* {
    if (currentState is TodosLoaded) {
      yield TodosLoading();
      try {
        repo.addTodos([
          event.todo,
        ]);

        yield TodosLoaded(
            todos: (await repo.loadItems()).map<Todo>(Todo.fromMap).toList(), event: event);
      } catch (err) {
        print(err);
        yield TodosNotLoaded();
      }
    }
  }

  Stream<TodoState> _mapUpdateTodo(UpdateTodo event) async* {
    if (currentState is TodosLoaded) {
      final newTodolist = (currentState as TodosLoaded)
          .todos
          .map((todoInList) =>
              todoInList.id == event.todo.id ? event.todo : todoInList)
          .toList();
      yield TodosLoaded(todos: newTodolist, event: event);
      repo.updateTodos([
        event.todo,
      ]);
    }
  }

  Stream<TodoState> _mapDeleteTodo(DeleteTodo event) async* {
    if (currentState is TodosLoaded) {
      final newTodolist = (currentState as TodosLoaded)
          .todos
          .where((todoInList) => todoInList.id != event.todo.id).toList();
      yield TodosLoaded(todos: newTodolist, event: event);
      repo.deleteTodos([event.todo]);
    }
  }

  Stream<TodoState> _mapDeleteAllTodos(DeleteAllTodos event) async* {
    if (currentState is TodosLoaded) {
      yield TodosLoaded(todos: [], event: event);
      repo.deleteAllItems();
    }
  }

// Debug
  Stream<TodoState> _mapDeleteDB(DeleteDB event) async* {
    yield TodosLoading();
    try {
      await this.repo.deleteDB();
      // final todos = await this.repo.loadTodos();
      yield TodosLoaded(todos: [], event: event);
    } catch (err) {
      print(err);
      yield TodosNotLoaded();
    }
  }
}
