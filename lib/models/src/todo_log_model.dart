import 'package:example_todolist/util/util.dart' as util;
import 'package:example_todolist/models/models.dart';

class TodoLog extends BaseModel {
  static const key_id = BaseModel.key_id;
  static const key_startTime = 'start_time';
  static const key_duration = 'duration';

  final int todoId;
  final DateTime startTime;
  final Duration duration;

  TodoLog({id, this.todoId, startTime, duration})
      : this.startTime = startTime is int
            ? DateTime.fromMillisecondsSinceEpoch(startTime)
            : startTime ?? DateTime.now(),
        this.duration =
            duration is int ? Duration(seconds: duration) : duration,
        super(id: id, otherAttrs: [startTime, duration]);

  static TodoLog fromMap(Map<String, dynamic> map) {
    return TodoLog(
        id: map[key_id],
        todoId: map[Todo.key_foreign],
        startTime: map[key_startTime],
        duration: map[key_duration]);
  }

  Map<String, dynamic> toMap({withId: true}) {
    return super.toMap(withId: withId)
      ..addAll(<String, dynamic>{
        Todo.key_foreign: todoId,
        key_startTime: startTime.millisecondsSinceEpoch,
        key_duration: duration?.inSeconds,
      });
  }

  TodoLog copyWith(
      {int id, DateTime startTime, Duration duration, int todoId}) {
    return TodoLog(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        duration: duration ?? this.duration,
        todoId: todoId ?? this.todoId);
  }

  @override
  String toString() {
    return "TodoTimeLog {$key_id: $id, ${Todo.key_foreign}: $todoId, ${key_startTime}: ${util.formatDateTime(startTime)}, $key_duration: ${util.formatDuration(duration)}}";
  }
}
