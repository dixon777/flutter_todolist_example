import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

abstract class SQLiteHelper {
  final String databaseName;
  final int version;
  final Lock _lock = Lock();

  SQLiteHelper(this.databaseName, this.version);

  Database _database;
  String _databasePath;

  FutureOr<Batch> get batch async {
    return (await database)?.batch();
  }

  FutureOr<Database> get database async {
    if (_database != null && _database.isOpen) {
      return _database;
    }

    await _lock.synchronized(() async {
      if (_database == null || !_database.isOpen) {
        _database = await openDatabase(
          join(await databasePath, databaseName),
          version: version,
          onConfigure: onConfigure,
          onCreate: onCreate,
          onOpen: onOpen,
          singleInstance: true,
        );
      }
    });

    return _database;
  }

  FutureOr<String> get databasePath async {
    if (_databasePath == null) {
      _databasePath = await getDatabasesPath();
      if (!await databaseExists(join(_databasePath, databaseName))) {
        await Directory(_databasePath).create(recursive: true);
      }
    }
    return _databasePath;
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

  FutureOr<void> onConfigure(Database db) async {
    // SQLite does not enable foreign key by default
    await db.execute("PRAGMA foreign_keys = ON");
  }

  FutureOr<void> onCreate(Database db, int version) async {}

  FutureOr<void> onOpen(Database db) async {
    
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
