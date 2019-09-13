import 'dart:async';

import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:example_todolist/settings/settings.dart' as settings;
import 'package:example_todolist/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoTrackingBloc>(
          builder: (context) {
            return TodoTrackingBloc(
                repo: TodoTrackingRepo(helper: TodolistSQLiteHelper()))
              ..dispatch(ReinitTodoTracking());
          },
        ),
        BlocProvider<TodoBloc>(
          builder: (context) =>
              TodoBloc(repo: TodoRepo(helper: TodolistSQLiteHelper()))
                ..dispatch(LoadTodos()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return TrackedTodoDeleteBlocListener(child: _displayWidget(context));
        },
      ),
    );
  }

  Widget _displayWidget(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                BlocProvider.of<TodoBloc>(context)?.dispatch(settings.deleteDB ? DeleteDB(): DeleteAllTodos());
              },
            )
          ],
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, todosState) {
              if (todosState is TodosNotLoaded || todosState is TodosLoading) {
                return SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text("Loading")
                      ],
                    ),
                  ),
                );
              } else if (todosState is TodosLoadFailure) {
                return GestureDetector(
                    onTap: () async => BlocProvider.of<TodoBloc>(context)
                        .dispatch(LoadTodos()),
                    child: Center(
                      child: Text(
                          "There is error in loading Todos. Press the screen to reload"),
                    ));
              }
              final todosInList = (todosState as TodosLoaded).todos;
              return BlocBuilder<TodoTrackingBloc, TodoTrackingState>(
                builder: (context, timeTrackingState) {
                  if (timeTrackingState is TodoTrackingUninit) {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Text("Loading")
                        ],
                      ),
                    );
                  }

                  final timeTrackingTodo = timeTrackingState is TodoTrackingOn
                      ? todosInList.firstWhere(
                          (t) => t.id == timeTrackingState.log.todoId,
                          orElse: () => null)
                      : null;
                  final todos = timeTrackingState is TodoTrackingOn
                      ? todosInList
                          .where((t) => t.id != (timeTrackingTodo.id))
                          .toList()
                      : todosInList;

                  final normalTodolist = <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: todos.length,
                      itemBuilder: (context, i) {
                        return TodoItemTile(
                          todo: todos[i],
                          anyTodoTracking: timeTrackingState is TodoTrackingOn,
                        );
                      },
                    ),
                  ];
                  if (timeTrackingTodo != null &&
                      timeTrackingState is TodoTrackingOn) {
                    normalTodolist.insert(
                        0,
                        TodoItemTile(
                          todo: timeTrackingTodo,
                          startTime: timeTrackingState.log.startTime,
                          anyTodoTracking: true,
                        ));
                  }
                  return Column(
                    children: normalTodolist,
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async => await _addTodo(context),
        ),
      ),
    );
  }

  Future<void> _addTodo(BuildContext context) async {
    final newTodo = await showDialog<Todo>(
        builder: (context) {
          return Dialog(child: TodoEditPage());
        },
        context: context);
    if (newTodo == null) return;
    BlocProvider.of<TodoBloc>(context)?.dispatch(AddTodo(newTodo));
  }
}



