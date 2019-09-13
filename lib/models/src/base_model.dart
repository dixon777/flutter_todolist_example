import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class BaseModel extends Equatable {
  static const key_id = 'id';

  final int id;
  BaseModel({this.id, @required List<dynamic> otherAttrs}) : super(otherAttrs..add(id));

  @mustCallSuper
  Map<String, dynamic> toMap({withId: true}) {
    final jsonMap = <String, dynamic>{};
    if (withId && id != null) {
      jsonMap[key_id] = key_id;
    }
    return jsonMap;
  }

  @override
  String toString() => "id: $id";
}
