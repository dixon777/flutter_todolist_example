import 'package:bloc/bloc.dart';
import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/repos/repo.dart';
import 'package:example_todolist/views/calendar/calendar_page.dart';
import 'package:example_todolist/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'settings/settings.dart' as settings;

void main() async {
  // Debug
  if (settings.debugDB) {
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
        home: MultiProvider(
          providers: [
            Provider<TodoListFragment>(
              builder: (context) => TodoListFragment(),
            ),
            Provider<CalendarFragment>(
              builder: (context) => CalendarFragment(),
            )
          ],
          child: FragmentScaffold(
              initFragment: TodoListFragment(),
              drawerBuilder: (context) {
                final todoListFragment = Provider.of<TodoListFragment>(context);
                final calendarFragment = Provider.of<CalendarFragment>(context);
                return Drawer(
                    child: ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text("Todo"),
                          onTap: () async {
                            FragmentScaffold.switchFragment(
                                context, todoListFragment);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text("Calendar"),
                          onTap: () async {
                            FragmentScaffold.switchFragment(
                                context, calendarFragment);
                            Navigator.pop(context);
                          },
                        )
                      ],
                    ),
                  );
              }),
        ));
  }
}
