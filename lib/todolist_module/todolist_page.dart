import 'dart:async';

import 'package:example_todolist/todolist_module/todolist_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_duration_picker/flutter_duration_picker.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

import '../global_setting.dart' as gs;
import 'todo_time_log_bloc.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoDbBloc>(
          builder: (context) =>
              TodoDbBloc()..dispatch(TodoEvent(type: TodoItemEventType.get)),
        ),
        BlocProvider<TodoTimeLogBloc>(
          builder: (context) => TodoTimeLogBloc(),
        ),
      ],
      child: Builder(
        builder: (context) => _displayWidget(context),
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
                BlocProvider.of<TodoDbBloc>(context)?.dispatch(TodoEvent(
                    type: gs.deleteDB
                        ? TodoItemEventType.deleteDB
                        : TodoItemEventType.deleteAll));
              },
            )
          ],
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: BlocBuilder<TodoDbBloc, TodoState>(
            builder: (context, state) {
              if (state == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: const CircularProgressIndicator(),
                );
              }

              return BlocBuilder<TodoTimeLogBloc, TodoTimeLogState>(
                builder: (context, timeLogState) {
                  final timeLoggingTodo = state.todos.firstWhere(
                      (t) => t.id == timeLogState.todoId,
                      orElse: () => null);
                  final todos =
                      timeLoggingTodo == null ? state.todos : state.todos
                        .where((t) => t != (timeLoggingTodo)).toList();

                  final normalTodolist = <Widget>[
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: todos.length,
                      itemBuilder: (context, i) {
                        return TodoItemTile(
                          todo: todos[i],
                          anyTodoLogging: timeLoggingTodo != null,
                        );
                      },
                    ),
                  ];
                  if (timeLoggingTodo != null) {
                    normalTodolist.insert(
                        0,
                        TodoItemTile(
                          todo: timeLoggingTodo,
                          startTime: timeLogState.startTime,
                          anyTodoLogging: true,
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
    BlocProvider.of<TodoDbBloc>(context)?.dispatch(
        TodoItemEvent(type: TodoItemEventType.add, todos: [newTodo]));
  }
}

class TodoItemTile extends StatefulWidget {
  final Todo todo;
  final DateTime startTime;
  final bool anyTodoLogging;

  const TodoItemTile({
    Key key,
    @required this.todo,
    this.startTime,
    this.anyTodoLogging: false,
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
    return Dismissible(
      key: Key(widget.todo.id.toString()),
      direction: widget.anyTodoLogging && widget.startTime == null
          ? DismissDirection.endToStart
          : DismissDirection.horizontal,
      child: ListTile(
        onTap: () => _onEdit(context),
        title: Text(widget.todo.title),
        subtitle: Text(DateFormat(gs.dateTimeFormat).format(widget.todo.due)),
        trailing: ConstrainedBox(
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
                  StreamBuilder(
                      stream: sub,
                      builder: (context, snapshot) {
                        return Text(gs.formatDuration(
                            widget.todo.totalDuration +
                                (snapshot.hasData
                                    ? snapshot.data
                                    : Duration(seconds: 0))));
                      }),
                ],
              )
            ],
          ),
          constraints: BoxConstraints(maxWidth: 80, minHeight: 100),
        ),
        leading: widget.startTime == null
            ? Checkbox(
                value: widget.todo.hasCompleted,
                onChanged: (bool value) async {
                  widget.todo.hasCompleted = value;
                  BlocProvider.of<TodoDbBloc>(context).dispatch(
                      TodoItemEvent(type: TodoItemEventType.update, todos: [
                    widget.todo,
                  ]));
                },
              )
            : ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 40, maxHeight: 32),
                child: FittedBox(
                    fit: BoxFit.contain, child: CircularProgressIndicator())),
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
        BlocProvider.of<TodoDbBloc>(context)
            .dispatch(TodoItemEvent(type: TodoItemEventType.delete, todos: [
          widget.todo,
        ]));
        BlocProvider.of<TodoTimeLogBloc>(context).dispatch(TodoTimeLogEvent(
            TodoTimeLogEventType.stop,
            todoId: widget.todo.id));
      },
    );
  }

  FutureOr<void> _triggerTimer(BuildContext context) async {
    if (widget.startTime == null) {
      BlocProvider.of<TodoTimeLogBloc>(context).dispatch(
          TodoTimeLogEvent(TodoTimeLogEventType.start, todoId: widget.todo.id));
      return;
    }

    final duration = DateTime.now().difference(widget.startTime);

    BlocProvider.of<TodoDbBloc>(context)
        .dispatch(TodoRecordEvent(type: TodoRecordEventType.add, records: [
      TodoRecord(
          duration: duration,
          startTime: widget.startTime,
          todoId: widget.todo.id)
    ]));

    BlocProvider.of<TodoTimeLogBloc>(context).dispatch(
        TodoTimeLogEvent(TodoTimeLogEventType.stop, todoId: widget.todo.id));
  }

  Future<void> _onEdit(BuildContext context) async {
    final editTodo = await showDialog<Todo>(
        builder: (context) {
          return Dialog(child: TodoEditPage(todo: widget.todo));
        },
        context: context);
    if (editTodo == null) return;

    BlocProvider.of<TodoDbBloc>(context).dispatch(
        TodoItemEvent(type: TodoItemEventType.update, todos: [editTodo]));
  }

}

class TodoEditPage extends StatefulWidget {
  final Todo todo;

  TodoEditPage({Key key, this.todo}) : super(key: key);
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
    _tcDateTime.text = DateFormat(gs.dateTimeFormat).format(todo.due);
    _tcExpectedDuration.text = todo.expectedDuration == null
        ? "Click here to set"
        : gs.formatDuration(todo.expectedDuration);
    _tcRecordedDuration.text = gs.formatDuration(todo.totalDuration);
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
          final n = DateTime.now();
          DateTime pickedDate = await showDatePicker(
            context: context,
            firstDate: n,
            initialDate: n.isAfter(todo.due) ? n : todo.due,
            lastDate: DateTime(todo.due.year + 100),
          );
          if (pickedDate == null) return;
          TimeOfDay pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(todo.due),
          );
          if (pickedTime == null) return;

          todo.due = pickedDate.add(
              Duration(hours: pickedTime.hour, minutes: pickedTime.minute));

          setState(() {
            _tcDateTime.text = DateFormat(gs.dateTimeFormat).format(todo.due);
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
          todo.expectedDuration = pickedDuration;
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
      children: todo.records
          .map<ListTile>((record) => ListTile(
                title: Text(gs.formatDuration(record.duration)),
                subtitle: Text(
                    "From ${DateFormat(gs.dateTimeFormat).format(record.startTime)}"),
              ))
          .toList(),
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
                  Navigator.pop<Todo>(context, todo..title = _tcTitle.text);
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
