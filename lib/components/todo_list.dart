import 'package:flutter/material.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/components/todo_list_tile.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onEdit;
  final Function(String) onDelete;
  final Function(String) onComplete;

  const TodoList({
    super.key,
    required this.todos,
    required this.onEdit,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoListTile(
          todo: todos[index],
          onEdit: onEdit,
          onDelete: onDelete,
          onComplete: onComplete,
        );
      },
    );
  }
}