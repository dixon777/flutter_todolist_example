import 'package:equatable/equatable.dart';
import 'package:example_todolist/blocs/todo/todo_bloc.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class TodoState extends Equatable {
  TodoState([List attrs = const []]) : super(attrs);
}

class TodosNotLoaded extends TodoState {
  @override
  String toString() => 'TodosNotLoaded';
}

class TodosLoading extends TodoState {
  @override
  String toString() => 'TodosLoading';
}

class TodosLoaded extends TodoState {
  final List<Todo> todos;
  final TodoEvent event;

  TodosLoaded({this.todos = const [], @required this.event}) : super([todos, event]);

  @override
  String toString() => 'TodosLoaded { todos: $todos }';
}

class TodosLoadFailure extends TodoState {
  @override
  String toString() => 'TodosLoadFailure';
}