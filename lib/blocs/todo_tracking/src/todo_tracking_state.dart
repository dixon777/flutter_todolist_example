import 'package:equatable/equatable.dart';
import 'package:example_todolist/blocs/blocs.dart';
import 'package:example_todolist/models/models.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class TodoTrackingState extends Equatable {
  final TodoTrackingEvent event;
  TodoTrackingState([this.event, List attrs = const []]) : super(<dynamic>[event]+attrs);
}

class TodoTrackingOn extends TodoTrackingState {
  // final Todo todo;
  final TodoLog log;

  TodoTrackingOn({@required event, this.log}): super(event, [log]);

  @override
  String toString() {
    return "TodoTrackingOn {event: $event, log: $log}";
  }
}

class TodoTrackingOff extends TodoTrackingState {
  // May require todo
  final TodoLog lastLog;

  TodoTrackingOff({@required event, this.lastLog}): super(event, [lastLog]);

  @override
  String toString() {
    return "TodoTrackingOff: {event: $event, lastLog: $lastLog}";
  }
}

class TodoTrackingUninit extends TodoTrackingState {
  TodoTrackingUninit({@required event}):super(event);

  @override
  String toString() {
    return "TodoTrackingUninit {event: $event}";
  }
}
