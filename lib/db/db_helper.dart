import 'dart:developer';

//import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'task';

  static Future<void> initDb() async {
    if (_db != null) {
      log('db not null');
      return;
    } else {
      try {
        log('in database path');
        String path = '${await getDatabasesPath()}task.db';
        _db = await openDatabase(path, version: _version,
            onCreate: (Database db, int version) async {
          // When creating the db, create the table
          return db.execute(
            'CREATE TABLE $_tableName('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'title STRING, note TEXT, date STRING, '
            'startTime STRING, endTime STRING, '
            'color INTEGER, remind INTEGER, isCompleted INTEGER, '
            'repeat STRING)',
          );
        });
        log('database created!!');
      } catch (e) {
        log('$e');
      }
    }
  }

  static Future<int> insert(Task task) async {
    log('insert function called');
    try {
      return await _db!.insert(_tableName, task.toJson());
    } catch (e) {
      log('we are here ........ $e');
      return 9000;
    }
  }

  static Future<int> delete(Task task) async {
    log('delete function called');
    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [task.id]);
  }

  static Future<int> deleteAll() async {
    log('delete all function called');
    return await _db!.delete(_tableName);
  }

  static Future<int> update(int id) async {
    log('update function called');
    return await _db!.rawUpdate('''
        UPDATE $_tableName
        SET isCompleted = ?
        WHERE id = ?
      ''', [1, id]);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    log('query function called');
    return await _db!.query(_tableName);
  }
}
