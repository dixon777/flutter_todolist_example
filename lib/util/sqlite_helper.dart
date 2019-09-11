import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class Item {
  static const key_id = 'id';

  int id;
  Item({this.id});

  

  @mustCallSuper
  Map<String, dynamic> toMap({withId: true}) {
    final jsonMap = <String, dynamic>{};
    if (withId && id != null) {
      jsonMap[key_id] = key_id;
    }
    return jsonMap;
  }
}

abstract class SQLiteDBHelper {
  final String databaseName;
  final int version;

  SQLiteDBHelper(this.databaseName, this.version);

  Database _database;

  FutureOr<Batch> get batch async {
    return (await database)?.batch();
  }

  FutureOr<Database> get database async {
    if (_database != null && _database.isOpen) {
      return _database;
    }

    final dbPath = await databasePath;
    if (!await databaseExists(join(dbPath, databaseName))) {
      await Directory(dbPath).create(recursive: true);
    }

    return await openDatabase(
      join(dbPath, databaseName),
      version: version,
      onCreate: onCreate,
      onOpen: onOpen,
      singleInstance: true,
    );
  }

  Future<String> get databasePath async {
    return await getDatabasesPath();
  }

  Future<void> closeDb() async {
    await _database?.close();
  }

  Future<void> deleteDb() async {
    final dbPath = await databasePath;
    if (dbPath == null) return;

    final db = await database;
    _database = null;
    await db.close();
    await Directory(dbPath)
        .list()
        .where((f) => basename(f.path) == databaseName)
        .forEach((f) async => f.delete());
  }

  FutureOr<List<dynamic>> performBatch(Batch batchActions(Batch batch)) async {
    final batch = await this.batch;
    if (batch == null) return null;
    return await (batchActions(batch).commit());
  }

  FutureOr<void> onCreate(Database db, int version) async {}

  FutureOr<void> onOpen(Database db) async {
    // SQLite does not enable foreign key by default
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> close() async {
    await closeDb();
  }
}

// abstract class SQLiteTableHelper<T extends SQLiteDBHelper>  {
//   final String tableName;
//   final T dbHelper;

//   SQLiteTableHelper(this.tableName, this.dbHelper):assert(tableName != null && dbHelper != null);

//   FutureOr<Database> get database async {
//     final db = await dbHelper.database;
//   }

//   void onCreateTable(T dbHelper, int version);

//   Future<int> deleteAll() async {
//     return (await database)?.delete(tableName, where: "1");
//   }
// }
