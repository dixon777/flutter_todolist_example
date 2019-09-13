import 'package:example_todolist/models/models.dart';
import 'package:flutter/material.dart';
import 'package:example_todolist/util/util.dart' as util;
import 'package:example_todolist/settings/settings.dart' as settings;
import 'package:flutter_duration_picker/flutter_duration_picker.dart';



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
        util.formatDateTime(todo.due, nullReplacement: settings.configureNullReplacement);
    _tcExpectedDuration.text = util.formatDuration(todo.expectedDuration,
        nullReplacement: settings.configureNullReplacement);
    _tcRecordedDuration.text = util.formatDuration(widget.logs.isEmpty
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
            lastDate: DateTime((todo.due?.year ?? now.year) + 100),
          );
          if (pickedDate == null) return;
          TimeOfDay pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(todo.due ?? now),
          );
          if (pickedTime == null) return;

          todo = todo.copyWith(
              due: pickedDate.add(Duration(
                  hours: pickedTime.hour, minutes: pickedTime.minute)));

          setState(() {
            _tcDateTime.text = util.formatDateTime(todo.due, nullReplacement: settings.configureNullReplacement);
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
            _tcExpectedDuration.text = util.formatDuration(todo.expectedDuration, nullReplacement: settings.configureNullReplacement);
          });
        });
  }

  Widget _textFieldLoggedDuration() {
    return ExpansionTile(
      title: TextField(
        readOnly: true,
        controller: _tcRecordedDuration,
        decoration: InputDecoration(
            labelText: "Recorded Duration", border: OutlineInputBorder()),
      ),
      children: widget.logs
              ?.map<ListTile>((record) => ListTile(
                    title: Text(util.formatDuration(record.duration)),
                    subtitle:
                        Text("From ${util.formatDateTime(record.startTime)}"),
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
              _textFieldFormatWrapper(child: _textFieldLoggedDuration()),
            ],
          ),
        ),
      ),
    );
  }
}
