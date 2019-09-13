import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs.dart';

class TrackedTodoDeleteBlocListener
    extends BlocListener<TodoBloc, TodoState> {
  TrackedTodoDeleteBlocListener({Widget child})
      : super(listener: _listener, child: child);

  static void _listener(BuildContext context, TodoState state) {
    if (state is TodosLoaded) {
      final event = state.event;
      if (event is DeleteTodo) {
        BlocProvider.of<TodoTrackingBloc>(context)
            ?.dispatch(CancelTodoTracking(todo:event.todo));
      } else if(event is DeleteDB || event is DeleteAllTodos) {
        BlocProvider.of<TodoTrackingBloc>(context)
            ?.dispatch(CancelTodoTracking());
      }
    }
  }
}