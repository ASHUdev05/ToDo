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
          'CREATE TABLE todos(id TEXT PRIMARY KEY, title TEXT, description TEXT)',
        );
      },
      version: 1,
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
    final List<Map<String, Object?>> todoMaps = await db.query('todos');
    return [
      for (final {
      'id': id as String,
      'title': title as String,
      'description': description as String,
      } in todoMaps)
        Todo(id: id, title: title, description: description),
    ];
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
}