import 'package:equatable/equatable.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class TodoLogEvent extends Equatable {
  TodoLogEvent([List attrs = const []]) : super(attrs);
}

class LoadTodoLogs extends TodoLogEvent {
  final Todo todo;

  LoadTodoLogs(this.todo);

  @override
  String toString() {
    return "LoadTodoLogs: {todo:$todo}";
  }
}

class AddTodoLog extends TodoLogEvent {
  final TodoLog log;

  AddTodoLog(this.log):super([log,]);

  @override
  String toString() {
    return "AddTodoLog: {log:$log}";
  }
}

class UpdateTodoLog extends TodoLogEvent {
  final TodoLog log;

  UpdateTodoLog(this.log):super([log,]);

  @override
  String toString() {
    return "UpdateTodoLog: {log:$log}";
  }
}

class DeleteTodoLog extends TodoLogEvent {
  final TodoLog log;

  DeleteTodoLog(this.log):super([log,]);

  @override
  String toString() {
    return "DeleteTodoLog: {log:$log}";
  }
}