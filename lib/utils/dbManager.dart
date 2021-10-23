import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseManager {
  // https://www.youtube.com/watch?v=UpKrhZ0Hppk
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;
  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('commutr.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  lat DOUBLE NOT NULL,
  lon DOUBLE NOT NULL,
  frequency INT NOT NULL,
);
    ''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
