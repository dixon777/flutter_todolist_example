import 'package:bloc/bloc.dart';

enum TodoTimeLogEventType { start, stop }

class TodoTimeLogEvent {
  final TodoTimeLogEventType type;
  final int todoId;

  TodoTimeLogEvent(this.type, {this.todoId});
}

class TodoTimeLogState {
  final int todoId;
  final DateTime startTime;

  final TodoTimeLogEvent event;

  TodoTimeLogState({this.event, this.todoId, this.startTime});
}

class TodoTimeLogBloc extends Bloc<TodoTimeLogEvent, TodoTimeLogState> {
  
  @override
  TodoTimeLogState get initialState => TodoTimeLogState();

  @override
  Stream<TodoTimeLogState> mapEventToState(TodoTimeLogEvent event) async* {
    switch (event.type) {
      case TodoTimeLogEventType.start:
        if (currentState.todoId == null) {
          yield TodoTimeLogState(event: event, todoId: event.todoId, startTime: DateTime.now());
        }
        break;
      case TodoTimeLogEventType.stop:
        if (currentState.todoId == event.todoId) {
          yield TodoTimeLogState(event: event);
        }
        break;
    }
  }
}
