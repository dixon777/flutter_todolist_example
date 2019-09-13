

import 'package:equatable/equatable.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class TodoTrackingEvent extends Equatable {
  TodoTrackingEvent([List attrs = const []]) : super(attrs);
}

class ReinitTodoTracking extends TodoTrackingEvent {
  @override
  String toString() {
    return "ReinitTodoTracking";
  }
}

class StartTodoTracking extends TodoTrackingEvent {
  final Todo todo;

  StartTodoTracking(this.todo):super([todo,]);

  @override
  String toString() {
    return "StartTodoTracking: {todo: $todo}";
  }
}

class StopTodoTracking extends TodoTrackingEvent {
  final Todo todo;

  StopTodoTracking(this.todo):super([todo,]);

  @override
  String toString() {
    return "StopTodoTracking: {todo: $todo}";
  }
}


class CancelTodoTracking extends TodoTrackingEvent {
  final Todo todo;

  CancelTodoTracking({this.todo}):super([todo,]);

  @override
  String toString() {
    return "CancelTodoTracking: {todo: $todo}";
  }
}