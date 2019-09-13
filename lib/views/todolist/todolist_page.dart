import 'dart:async';

import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:example_todolist/settings/settings.dart' as settings;
import 'package:example_todolist/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// class TodoListPage extends Fragment {
//   @override
//   Widget build(BuildContext context) {

//   }
// }
class TodoListFragment extends Fragment {
  PreferredSizeWidget appBarBuilder(BuildContext context) => AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              BlocProvider.of<TodoBloc>(context)
                  ?.dispatch(settings.deleteDB ? DeleteDB() : DeleteAllTodos());
            },
          )
        ],
      );

  Widget bodyBuilder(BuildContext context) {
    return Container(
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
                onTap: () async =>
                    BlocProvider.of<TodoBloc>(context).dispatch(LoadTodos()),
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
    );
  }

  Widget floatingActionButtonBuilder(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async => await _addTodo(context),
    );
  }

  Future<void> _addTodo(BuildContext context) async {
    final newTodo = await Navigator.push(
        context,
        MaterialPageRoute<Todo>(
            builder: (context) => TodoEditPage(
                  title: "Add new todo",
                ),
            settings: RouteSettings(name: "addTodo")));
    if (newTodo == null) return;
    BlocProvider.of<TodoBloc>(context)?.dispatch(AddTodo(newTodo));
  }

  @override
  Widget preBuilder(BuildContext context, WidgetBuilder scaffoldBuilder) {
    return Provider<SelfDefinedSQLiteHelper>(
        child: Builder(builder: (context) {
          final sqliteHelper = Provider.of<SelfDefinedSQLiteHelper>(context);
          return MultiBlocProvider(
            providers: [
              BlocProvider<TodoTrackingBloc>(
                builder: (context) {
                  return TodoTrackingBloc(
                      repo: TodoTrackingRepo(helper: sqliteHelper))
                    ..dispatch(ReinitTodoTracking());
                },
              ),
              BlocProvider<TodoBloc>(
                builder: (context) =>
                    TodoBloc(repo: TodoRepo(helper: sqliteHelper))
                      ..dispatch(LoadTodos()),
              ),
            ],
            child: Builder(
              builder: (context) {
                return TrackedTodoDeleteBlocListener(
                    child: scaffoldBuilder(context));
              },
            ),
          );
        }),
        builder: (BuildContext context) => SelfDefinedSQLiteHelper(),
      );
  }
}
