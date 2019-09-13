import 'dart:async';

import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/repo/repo.dart';
import 'package:example_todolist/repo/src/todo_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:rxdart/rxdart.dart';

import 'global_setting.dart' as gs;
import 'models/models.dart';

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
                BlocProvider.of<TodoBloc>(context)?.dispatch(gs.deleteDB ? DeleteDB(): DeleteAllTodos());
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
    return BlocProvider<TodoLogBloc>(
      builder: (context) =>
          TodoLogBloc(repo: TodoLogRepo(helper: TodolistSQLiteHelper()))
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
        onTap: () => _onEdit(context),
        title: Text(widget.todo.title),
        subtitle: Text(gs.formatDateTime(widget.todo.due)),
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
              Text(gs.formatDuration(widget.todo.expectedDuration))
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
                      return Text(gs.formatDuration(totalDuration +
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
    if (widget.startTime == null) {
      BlocProvider.of<TodoTrackingBloc>(context)
          .dispatch(StartTodoTracking(widget.todo));
      return;
    }
    BlocProvider.of<TodoTrackingBloc>(context)
        .dispatch(StopTodoTracking(widget.todo));
  }

  Future<void> _onEdit(BuildContext context) async {
    final TodoLogState todoLogState =
        BlocProvider.of<TodoLogBloc>(context).currentState;
    final logs = todoLogState is TodoLogsLoaded ? todoLogState.logs : [];
    final editTodo = await showDialog<Todo>(
        builder: (context) {
          return Dialog(child: TodoEditPage(todo: widget.todo, logs: logs));
        },
        context: context);
    if (editTodo == null) return;

    BlocProvider.of<TodoBloc>(context).dispatch(UpdateTodo(editTodo));
  }
}

class TodoEditPage extends StatefulWidget {
  final Todo todo;
  final List<TodoLog> logs;

  TodoEditPage({Key key, this.todo, this.logs:const[]}) : super(key: key);
  @override
  _TodoEditPageState createState() => _TodoEditPageState();
}

class _TodoEditPageState extends State<TodoEditPage> {
  final TextEditingController _tcTitle = TextEditingController();
  final TextEditingController _tcDateTime = TextEditingController();
  final TextEditingController _tcExpectedDuration = TextEditingController();
  final TextEditingController _tcRecordedDuration = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Todo todo;

  @override
  void initState() {
    super.initState();

    todo = widget.todo ?? Todo();

    _tcTitle.text = todo.title;
    _tcDateTime.text =
        gs.formatDateTime(todo.due, nullReplacement: "Click here to set");
    _tcExpectedDuration.text = gs.formatDuration(todo.expectedDuration,
        nullReplacement: "Click here to set");
    _tcRecordedDuration.text = gs.formatDuration(widget.logs.isEmpty
        ? Duration(seconds: 0)
        : widget.logs
            .map<Duration>((log) => log.duration)
            ?.reduce((a, b) => a + b));
  }

  Widget _textFieldFormatWrapper({Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: child,
    );
  }

  Widget _textFieldName() {
    return TextFormField(
      controller: _tcTitle,
      validator: (str) {
        return str.isEmpty ? "Title should not be empty" : null;
      },
      decoration:
          InputDecoration(labelText: "Title", border: OutlineInputBorder()),
    );
  }

  Widget _textFieldDue() {
    return TextField(
        readOnly: true,
        controller: _tcDateTime,
        decoration: InputDecoration(
            labelText: "Due date (Optional)", border: OutlineInputBorder()),
        onTap: () async {
          final now = DateTime.now();
          DateTime pickedDate = await showDatePicker(
            context: context,
            firstDate: now,
            initialDate:
                todo.due == null || now.isAfter(todo.due) ? now : todo.due,
            lastDate: DateTime(todo.due.year + 100),
          );
          if (pickedDate == null) return;
          TimeOfDay pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(todo.due),
          );
          if (pickedTime == null) return;

          todo = todo.copyWith(
              due: pickedDate.add(Duration(
                  hours: pickedTime.hour, minutes: pickedTime.minute)));

          setState(() {
            _tcDateTime.text = gs.formatDateTime(todo.due);
          });
        });
  }

  Widget _textFieldExpectedDuration() {
    return TextField(
        readOnly: true,
        controller: _tcExpectedDuration,
        decoration: InputDecoration(
            labelText: "Expected Duration", border: OutlineInputBorder()),
        onTap: () async {
          final pickedDuration = await showDurationPicker(
            context: context,
            initialTime: todo.expectedDuration ?? Duration(minutes: 0),
          );
          todo = todo.copyWith(expectedDuration: pickedDuration);
          setState(() {
            _tcExpectedDuration.text = gs.formatDuration(todo.expectedDuration);
          });
        });
  }

  Widget _textFieldRecordedDuration() {
    return ExpansionTile(
      title: TextField(
        readOnly: true,
        controller: _tcRecordedDuration,
        decoration: InputDecoration(
            labelText: "Recorded Duration", border: OutlineInputBorder()),
      ),
      children: widget.logs
              ?.map<ListTile>((record) => ListTile(
                    title: Text(gs.formatDuration(record.duration)),
                    subtitle:
                        Text("From ${gs.formatDateTime(record.startTime)}"),
                  ))
              ?.toList() ??
          [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop<Todo>(
                      context, todo.copyWith(title: _tcTitle.text));
                  return;
                } else {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text("Some fields are invalid")));
                }
              },
            ),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          autovalidate: true,
          child: ListView(
            children: <Widget>[
              _textFieldFormatWrapper(child: _textFieldName()),
              _textFieldFormatWrapper(child: _textFieldDue()),
              _textFieldFormatWrapper(child: _textFieldExpectedDuration()),
              _textFieldFormatWrapper(child: _textFieldRecordedDuration()),
            ],
          ),
        ),
      ),
    );
  }
}
