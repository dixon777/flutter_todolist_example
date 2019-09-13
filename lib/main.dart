import 'package:bloc/bloc.dart';
import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:example_todolist/views/views.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'settings/settings.dart' as settings;

void main() async {
  // Debug
  if(settings.debugDB) {
    BlocSupervisor.delegate = CustomBlocDelegate();
  await Sqflite.devSetDebugModeOn(settings.debugDB);
  }
  
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
          home: Provider<TodolistSQLiteHelper>(child: TodoListPage(), builder: (BuildContext context) {
            return TodolistSQLiteHelper();
          },),
    );
  }
}
