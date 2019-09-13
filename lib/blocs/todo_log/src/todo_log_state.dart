import 'package:equatable/equatable.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class TodoLogState extends Equatable {
  TodoLogState([List attrs = const []]) : super(attrs);
}

class TodoLogNotLoaded extends TodoLogState {
  @override
  String toString() {
    return "TodoLogNotLoaded";
  }
}

class TodoLogsLoading extends TodoLogState {
  @override
  String toString() {
    return "TodoLogsLoading";
  }
}

class TodoLogsLoadFail extends TodoLogState {
  @override
  String toString() {
    return "TodoLogsLoadFail";
  }
}

class TodoLogsLoaded extends TodoLogState {
  
  final List<TodoLog> logs;

  TodoLogsLoaded(this.logs):super([logs,]);

  @override
  String toString() {
    return "TodoLogsLoaded: {logs: $logs}";
  }
}