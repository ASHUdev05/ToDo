import 'package:flutter/material.dart';
import 'package:todo_offline/components/todo_form.dart';
import 'package:todo_offline/model/todo.dart';

class AddTodoScreen extends StatelessWidget {
  final void Function(Todo todo) onAddTodo;
  final Todo? todo;

  const AddTodoScreen({
    super.key,
    required this.onAddTodo,
    this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(todo != null ? 'Edit Todo' : 'Add Todo'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: TodoForm(
            onAddTodo: onAddTodo,
            todo: todo,
          ),
        ),
      ),
    );
  }
}