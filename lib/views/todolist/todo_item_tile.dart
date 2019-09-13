import 'dart:async';

import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'package:example_todolist/util/util.dart' as util;

import 'package:example_todolist/views/views.dart';

class TodoItemTile extends StatefulWidget {
  final Todo todo;
  final DateTime startTime;
  final bool anyTodoTracking;

  const TodoItemTile({
    Key key,
    @required this.todo,
    this.startTime,
    this.anyTodoTracking: false,
  }) : super(key: key);

  @override
  _TodoItemTileState createState() => _TodoItemTileState();
}

class _TodoItemTileState extends State<TodoItemTile> {
  Observable sub;
  @override
  void initState() {
    sub = Observable.periodic(Duration(seconds: 1),
        (i) => DateTime.now().difference(widget.startTime)).asBroadcastStream();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final todoLogBloc = BlocBuilder<TodoLogBloc, TodoLogState>(
        builder: (BuildContext context, TodoLogState todoLogState) {
      return _displayWidget(context);
    });
    final sqliteHelper = Provider.of<SelfDefinedSQLiteHelper>(context);
    return BlocProvider<TodoLogBloc>(
      builder: (context) => TodoLogBloc(repo: TodoLogRepo(helper: sqliteHelper))
        ..dispatch(LoadTodoLogs(widget.todo)),
      child: Builder(
        builder: (context) => widget.startTime != null
            ? TodoTrackingStopBlocListener(
                child: todoLogBloc,
              )
            : todoLogBloc,
      ),
    );
  }

  Widget _displayWidget(BuildContext context) {
    return Dismissible(
      key: Key(widget.todo.id.toString()),
      direction: widget.anyTodoTracking && widget.startTime == null
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      child: ListTile(
        onTap: () => _onEditTodo(context),
        title: Text(widget.todo.title),
        subtitle: Text(util.formatDateTime(widget.todo.due)),
        trailing: _trailingWidget(context),
        leading: _leadingWidget(context),
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        color: Colors.blue,
        child: Icon(widget.startTime == null ? Icons.timer : Icons.timer_off),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        color: Colors.red,
        child: Icon(Icons.delete),
      ),
      confirmDismiss: (direction) {
        return Future(() {
          if (direction == DismissDirection.endToStart) return true;
          _triggerTimer(context);
          return false;
        });
      },
      onDismissed: (direction) {
        BlocProvider.of<TodoBloc>(context).dispatch(DeleteTodo(
          widget.todo,
        ));
      },
    );
  }

  Widget _leadingWidget(BuildContext context) {
    return widget.startTime == null
        ? Checkbox(
            value: widget.todo.complete,
            onChanged: (bool value) async {
              BlocProvider.of<TodoBloc>(context)
                  .dispatch(UpdateTodo(widget.todo.copyWith(complete: value)));
            },
          )
        : ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 40, maxHeight: 32),
            child: FittedBox(
                fit: BoxFit.contain, child: CircularProgressIndicator()));
  }

  Widget _trailingWidget(BuildContext context) {
    return ConstrainedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.playlist_play),
              Text(util.formatDuration(widget.todo.expectedDuration))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.av_timer),
              Builder(builder: (context) {
                final TodoLogState todoLogState =
                    BlocProvider.of<TodoLogBloc>(context).currentState;
                if (todoLogState is TodoLogNotLoaded ||
                    todoLogState is TodoLogsLoading ||
                    todoLogState is TodoLogsLoadFail) {
                  return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 40, maxHeight: 32),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: CircularProgressIndicator()));
                }
                final logs = (todoLogState as TodoLogsLoaded).logs;
                final totalDuration = logs.isEmpty
                    ? Duration(seconds: 0)
                    : logs
                        .map<Duration>((log) => log.duration)
                        .reduce((a, b) => a + b);
                return StreamBuilder(
                    stream: sub,
                    builder: (context, snapshot) {
                      return Text(util.formatDuration(totalDuration +
                          (snapshot.hasData
                              ? snapshot.data
                              : Duration(seconds: 0))));
                    });
              }),
            ],
          )
        ],
      ),
      constraints: BoxConstraints(maxWidth: 80, minHeight: 100),
    );
  }

  FutureOr<void> _triggerTimer(BuildContext context) async {
    BlocProvider.of<TodoTrackingBloc>(context).dispatch(widget.startTime == null
        ? StartTodoTracking(widget.todo)
        : StopTodoTracking(widget.todo));
  }

  Future<void> _onEditTodo(BuildContext context) async {
    final TodoLogState todoLogState =
        BlocProvider.of<TodoLogBloc>(context).currentState;
    final logs = todoLogState is TodoLogsLoaded ? todoLogState.logs : [];
    final editTodo = await Navigator.push(
        context,
        MaterialPageRoute<Todo>(
            builder: (context) => TodoEditPage(title:"Edit todo",todo: widget.todo, logs: logs),
            settings: RouteSettings(name: "editTodo")));
    if (editTodo == null) return;

    BlocProvider.of<TodoBloc>(context).dispatch(UpdateTodo(editTodo));
  }
}
