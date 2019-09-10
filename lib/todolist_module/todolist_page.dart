import 'package:example_todolist/todolist_module/todolist_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../global_setting.dart' as gs;

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>(
      builder: (context) => TodoBloc()..dispatch(TodoEvent(TodoEventType.get)),
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
                BlocProvider.of<TodoBloc>(context)
                    ?.dispatch(TodoEvent(TodoEventType.deleteDB));
              },
            )
          ],
        ),
        body: Container(
          alignment: Alignment.topCenter,
          child: BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              if (state == null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: const CircularProgressIndicator(),
                );
              }
              final todolist = state.todos;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: todolist.length,
                itemBuilder: (context, i) {
                  return TodoListTile(todo: todolist[i]);
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
    BlocProvider.of<TodoBloc>(context)
        ?.dispatch(TodoEvent(TodoEventType.add, todos: [newTodo]));
  }
}

class TodoListTile extends StatelessWidget {
  const TodoListTile({
    Key key,
    @required this.todo,
  }) : super(key: key);

  final Todo todo;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(todo.id.toString()),
      child: ListTile(
        onTap: () => _onEdit(context),
        title: Text(todo.name),
        subtitle: Text(DateFormat(gs.dateTimeFormat).format(todo.due)),
        leading: Checkbox(
          value: todo.hasCompleted,
          onChanged: (bool value) async {
            todo.hasCompleted = value;
            BlocProvider.of<TodoBloc>(context)
                .dispatch(TodoEvent(TodoEventType.update, todos: [
              todo,
            ]));
          },
        ),
      ),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        color: Colors.blue,
        child: Icon(Icons.edit),
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
          _onEdit(context);
          return false;
        });
      },
      onDismissed: (direction) {
        BlocProvider.of<TodoBloc>(context)
            .dispatch(TodoEvent(TodoEventType.delete, todos: [
          todo,
        ]));
      },
    );
  }

  Future<void> _onEdit(BuildContext context) async {
    final editTodo = await showDialog<Todo>(
        builder: (context) {
          return Dialog(child: TodoEditPage(todo: todo));
        },
        context: context);
    print(editTodo);
    if (editTodo == null) return;

    BlocProvider.of<TodoBloc>(context)
        .dispatch(TodoEvent(TodoEventType.update, todos: [editTodo]));
  }
}

class TodoEditPage extends StatefulWidget {
  final Todo todo;

  TodoEditPage({Key key, this.todo}) : super(key: key);
  @override
  _TodoEditPageState createState() => _TodoEditPageState();
}

class _TodoEditPageState extends State<TodoEditPage> {
  TextEditingController _textControllerName;
  TextEditingController _textControllerDate;
  TextEditingController _textControllerTime;

  Todo todo;

  @override
  void initState() {
    super.initState();

    todo = widget.todo ?? Todo();
    todo.name ??= "";
    todo.due ??= DateTime.now();

    _textControllerName = TextEditingController(text: todo.name);
    _textControllerDate =
        TextEditingController(text: DateFormat(gs.dateFormat).format(todo.due));
    _textControllerTime =
        TextEditingController(text: DateFormat(gs.timeFormat).format(todo.due));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => Navigator.pop<Todo>(
                context, todo..name = _textControllerName.text),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              controller: _textControllerName,
              onChanged: (s) async {
                todo.name = s;
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: "Date (Due)"),
              controller: _textControllerDate,
              readOnly: true,
              onTap: () async {
                final n = DateTime.now();
                DateTime date = await showDatePicker(
                  context: context,
                  firstDate: n,
                  initialDate: n.isAfter(todo.due) ? n : todo.due,
                  lastDate: DateTime(todo.due.year + 100),
                );
                todo.due = date.add(
                    Duration(hours: todo.due.hour, minutes: todo.due.minute));

                setState(() {
                  _textControllerDate.text =
                      DateFormat(gs.dateFormat).format(todo.due);
                });
              },
            ),
            TextField(
                decoration: InputDecoration(labelText: "Time (Due)"),
                controller: _textControllerTime,
                readOnly: true,
                onTap: () async {
                  TimeOfDay timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(todo.due),
                  );
                  todo.due = todo.due.add(Duration(
                          hours: timeOfDay.hour, minutes: timeOfDay.minute) -
                      Duration(hours: todo.due.hour, minutes: todo.due.minute));
                  setState(() {
                    _textControllerTime.text =
                        DateFormat(gs.timeFormat).format(todo.due);
                  });
                }),
          ],
        ),
      ),
    );
  }
}
