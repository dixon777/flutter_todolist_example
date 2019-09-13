import 'package:bloc/bloc.dart';
import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/repo/repo.dart';
import 'package:example_todolist/todolist_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'global_setting.dart' as gb;

void main() async {
  // Debug
  if(gb.debugDB) {
    BlocSupervisor.delegate = CustomBlocDelegate();
  await Sqflite.devSetDebugModeOn(gb.debugDB);
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
