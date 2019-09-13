import 'package:example_todolist/util/util.dart' as util;

import '../models.dart';

class Todo extends BaseModel {
  static const key_id = BaseModel.key_id;
  static const key_title = 'title';
  static const key_complete = 'complete';
  static const key_due = 'due';
  static const key_expectedDuration = 'expected_duration';
  static const key_records = 'records';

  static const key_foreign = 'todo_id';

  final String title;
  final bool complete;
  final DateTime due;
  final Duration expectedDuration;
  // List<TodoRecord> records;

  // Duration get totalDuration => records.isEmpty
  //       ? Duration(seconds: 0)
  //       : records.map((r) => r.duration).reduce((val, d) => val + d);

  Todo({id, title, due, complete, expectedDuration, records})
      : this.title = title ?? "",
        this.due = due,
        this.complete = complete is int
            ? complete > 0
            : complete is bool ? complete : false,
        this.expectedDuration = expectedDuration,
        // this.records = records ?? [],
        super(id: id, otherAttrs: [title, due, complete, expectedDuration]);

  static Todo fromMap(Map<String, dynamic> map) {
    final due = map[key_due] != null
        ? DateTime.fromMillisecondsSinceEpoch(map[key_due])
        : null;
    final expectedDuration = map[key_expectedDuration] != null
        ? Duration(seconds: map[key_expectedDuration])
        : null;
    return Todo(
      id: map[Todo.key_id],
      title: map[key_title],
      complete: map[key_complete],
      due: due,
      expectedDuration: expectedDuration,
    );
    // records: map[key_records]
    // ?.map<TodoRecord>((recordMap) => TodoRecord.fromMap(recordMap))
    //     ?.toList());
  }

  @override
  Map<String, dynamic> toMap({withId: true}) {
    return super.toMap(withId: withId)
      ..addAll(<String, dynamic>{
        key_title: title,
        key_due: due?.millisecondsSinceEpoch,
        key_complete: complete ? 1 : 0,
        key_expectedDuration: expectedDuration?.inSeconds,
      });

    // if (withRecords) {
    //   jsonMap[key_records] =
    //       records.map<Map>((record) => record.toMap(withId: true)).toList();
    // }
  }

  Todo copyWith(
      {int id,
      String title,
      bool complete,
      DateTime due,
      Duration expectedDuration}) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      complete: complete ?? this.complete,
      due: due ?? this.due,
      expectedDuration: expectedDuration ?? this.expectedDuration,
    );
  }

  @override
  String toString() {
    return "Todo {$key_id: $id, $key_title: $title, $key_complete: $complete, $key_due: ${util.formatDateTime(due)}, $key_expectedDuration: ${util.formatDuration(expectedDuration)}}";
  }
}
