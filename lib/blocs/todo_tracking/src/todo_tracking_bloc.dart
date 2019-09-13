import 'package:bloc/bloc.dart';
import 'package:example_todolist/blocs/todo_tracking/todo_tracking_bloc.dart';
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/src/todo_tracking_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../blocs.dart';

class TodoTrackingBloc extends Bloc<TodoTrackingEvent, TodoTrackingState> {
  TodoTrackingRepo repo;

  TodoTrackingBloc({@required this.repo});

  @override
  TodoTrackingState get initialState => TodoTrackingUninit(event: null);


  @override
  Stream<TodoTrackingState> mapEventToState(TodoTrackingEvent event) async* {
    if (event is StartTodoTracking) {
      yield* _mapStart(event);
    } else if (event is StopTodoTracking) {
      yield* _mapStop(event);
    } else if (event is CancelTodoTracking) {
      yield* _mapCancel(event);
    } else if (event is ReinitTodoTracking) {
      yield* _mapReinit(event);
    }
  }

  Stream<TodoTrackingState> _mapStart(StartTodoTracking event) async* {
    final state = currentState;
    if(state is TodoTrackingUninit || state is TodoTrackingOn) return;
    repo.deleteAllItems();
    // final log = TodoLog(todoId: event.todo.id);
    repo.addTodoLogs([TodoLog(todoId: event.todo.id)]);
    final log = (await repo.loadTodoLogs())[0];
    yield TodoTrackingOn(event: event, log: log);
  }

  Stream<TodoTrackingState> _mapStop(StopTodoTracking event) async* {
    final state = currentState;
    if(state is TodoTrackingUninit || state is TodoTrackingOff) return;

    final currentLog = (currentState as TodoTrackingOn).log;
    yield TodoTrackingOff(event: event, lastLog: currentLog.copyWith(duration: DateTime.now().difference(currentLog.startTime)));
    repo.deleteAllItems();
  }

  Stream<TodoTrackingState> _mapCancel(CancelTodoTracking event) async* {
    final state = currentState;
    if(state is TodoTrackingUninit || state is TodoTrackingOff) return;

    final currentLog = (currentState as TodoTrackingOn).log;
    yield TodoTrackingOff(event: event, lastLog: currentLog);
    repo.deleteAllItems();
  }

  Stream<TodoTrackingState> _mapReinit(ReinitTodoTracking event) async* {
    final state = currentState;
    
    if(state is! TodoTrackingUninit) return;
    
    final logs = await repo.loadTodoLogs();
    if (logs.length > 0) {
      yield TodoTrackingOn(event: event, log: logs[0]);
    } else {
      yield TodoTrackingOff(event: event, lastLog: null);
    }
  }
}


