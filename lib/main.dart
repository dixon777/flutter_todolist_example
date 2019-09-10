import 'package:example_todolist/todolist_module/todolist_module.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'global_setting.dart' as gb;

void main() async {
  await Sqflite.devSetDebugModeOn(gb.debugDB);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Persistence Todo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TodoListPage());
  }
}
