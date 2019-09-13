import 'package:equatable/equatable.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class TodoEvent extends Equatable {
  TodoEvent([List attrs = const []]) : super(attrs);
}

class LoadTodos extends TodoEvent {
  @override
  String toString() => 'LoadTodos';
}

class AddTodo extends TodoEvent {
  final Todo todo;

  AddTodo(this.todo) : super([todo]);

  @override
  String toString() => 'AddTodo { todo: $todo }';
}

class UpdateTodo extends TodoEvent {
  final Todo todo;

  UpdateTodo(this.todo) : super([todo]);

  @override
  String toString() => 'UpdateTodo { updatedTodo: $todo }';
}

class DeleteTodo extends TodoEvent {
  final Todo todo;

  DeleteTodo(this.todo) : super([todo]);

  @override
  String toString() => 'DeleteTodo { todo: $todo }';
}


class ClearCompleted extends TodoEvent {
  @override
  String toString() => 'ClearCompleted';
}

class DeleteAllTodos extends TodoEvent {
  @override
  String toString() => 'DeleteAllTodos';
}
// DEBUG
class DeleteDB extends TodoEvent {
  @override
  String toString() => 'DeleteDB';
}

// class ToggleAll extends TodosEvent {
//   @override
//   String toString() => 'ToggleAll';
// }