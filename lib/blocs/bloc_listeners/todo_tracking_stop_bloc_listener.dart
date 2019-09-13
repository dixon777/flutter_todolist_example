import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs.dart';

class TodoTrackingStopBlocListener
    extends BlocListener<TodoTrackingBloc, TodoTrackingState> {
  TodoTrackingStopBlocListener({Widget child})
      : super(listener: _listener, child: child);

  static void _listener(BuildContext context, TodoTrackingState state) {
    if (state is TodoTrackingOff) {
      final event = state.event;

      if (event is StopTodoTracking) {
        BlocProvider.of<TodoLogBloc>(context)
            ?.dispatch(AddTodoLog(state.lastLog));
      }
    }
  }
}
