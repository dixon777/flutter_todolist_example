import 'dart:async';

import 'package:example_todolist/models/models.dart';
import 'package:example_todolist/util/util.dart';
import 'package:sqflite/sqflite.dart';

class BaseRepo {
  final SQLiteHelper helper;
  final String tableName;
  BaseRepo({this.helper, this.tableName});

  Future<List<Map<String, dynamic>>> loadItems() async {
    return (await this.helper.database).query(tableName);
  }

  Future<void> addItems(Iterable<Map<String, dynamic>> maps) async {
    final batch = (await this.helper.database).batch();
    maps.forEach((map) => batch.insert(tableName, map,
        conflictAlgorithm: ConflictAlgorithm.replace));
    batch.commit();
  }

  Future<void> updateItems(Iterable<Map<String, dynamic>> maps) async {
    final batch = (await this.helper.database).batch();
    maps.forEach((map) {
      final id = map[BaseModel.key_id];
      batch
          .update(tableName, map, where: "${BaseModel.key_id} = ?", whereArgs: [
        id,
      ]);
    });
    batch.commit();
  }

  Future<void> deleteItemsOfPrimaryKeys(Iterable<int> ids) async {
    final db = await this.helper.database;

    final batch = db.batch();
    ids.forEach((id) => batch
        .delete(tableName, where: "${BaseModel.key_id} = ?", whereArgs: [id]));
    batch.commit();
  }

  Future<int> deleteAllItems() async {
    final db = (await this.helper.database);
    if (db == null || !db.isOpen) return 0;

    return db?.delete(tableName, where: "1");
  }
}
