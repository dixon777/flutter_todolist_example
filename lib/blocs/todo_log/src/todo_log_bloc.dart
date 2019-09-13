import 'package:bloc/bloc.dart';
import 'package:example_todolist/blocs/todo_log/todo_log_bloc.dart';
import 'package:example_todolist/repo/repo.dart';
import 'package:flutter/foundation.dart';

class TodoLogBloc extends Bloc<TodoLogEvent, TodoLogState> {
  final TodoLogRepo repo;

  TodoLogBloc({@required this.repo});

  @override
  TodoLogState get initialState => TodoLogNotLoaded();

  @override
  Stream<TodoLogState> mapEventToState(TodoLogEvent event) async* {
    if (event is LoadTodoLogs) {
      yield* _mapLoadTodoLog(event);
    } else if (event is AddTodoLog) {
      yield* _mapAddTodoLog(event);
    } else if (event is UpdateTodoLog) {
      yield* _mapUpdateTodoLog(event);
    } else if (event is DeleteTodoLog) {
      yield* _mapDeleteTodoLog(event);
    }
  }

  Stream<TodoLogState> _mapLoadTodoLog(LoadTodoLogs event) async* {
    if (currentState is! TodoLogsLoading) {
      yield TodoLogsLoading();
    }
    try {
      final logs = await repo.loadTodoLogs();
      yield TodoLogsLoaded(logs);
    } catch (err) {
      print(err);
      yield TodoLogsLoadFail();
    }
  }

  Stream<TodoLogState> _mapAddTodoLog(AddTodoLog event) async* {
    if (currentState is TodoLogsLoaded) {
      yield TodoLogsLoading();
      try {
        repo.addTodoLogs([event.log]);
        final logs = await repo.loadTodoLogs();
        yield TodoLogsLoaded(logs);
      } catch (err) {
        print(err);
        yield TodoLogsLoadFail();
      }
    }
  }

  Stream<TodoLogState> _mapUpdateTodoLog(UpdateTodoLog event) async* {
    if (currentState is TodoLogsLoaded) {
      final newTodolist = (currentState as TodoLogsLoaded)
          .logs
          .map((log) => log.id == event.log.id ? event.log : log);
      yield TodoLogsLoaded(newTodolist);

      repo.updateTodoLogs([event.log]);
    }
  }

  Stream<TodoLogState> _mapDeleteTodoLog(DeleteTodoLog event) async* {
    if (currentState is TodoLogsLoaded) {
      final newTodolist = (currentState as TodoLogsLoaded)
          .logs
          .where((log) => log.id != event.log.id);
      yield TodoLogsLoaded(newTodolist);
      repo.deleteTodoLogs([
        event.log,
      ]);
    }
  }
}
