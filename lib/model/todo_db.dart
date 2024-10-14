import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_offline/model/todo.dart';

class TodoDatabase {
  static final TodoDatabase _instance = TodoDatabase._internal();
  late Future<Database> database;

  factory TodoDatabase() {
    return _instance;
  }

  TodoDatabase._internal() {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(getDatabasesPath().toString(), 'todo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, description TEXT, isCompleted INTEGER)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE todos ADD COLUMN isCompleted INTEGER DEFAULT 0');
        }
      },
      version: 2,
    );
  }

  Future<void> insertTodo(Todo todo) async {
    final db = await database;
    await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> todoMaps = await db.query('todos');
    return List.generate(todoMaps.length, (i) {
      return Todo(
        id: todoMaps[i]['id'],
        title: todoMaps[i]['title'],
        description: todoMaps[i]['description'],
        isCompleted: todoMaps[i]['isCompleted'] == 1,
      );
    });
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await database;
    await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<void> deleteTodo(String id) async {
    final db = await database;
    await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> completeTodo(String id) async {
    final db = await database;
    final todo = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.update(
      'todos',
      {
        'isCompleted': todo[0]['isCompleted'] == 1 ? 0 : 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}