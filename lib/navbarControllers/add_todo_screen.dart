import 'package:flutter/material.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/model/todo_db.dart';
import 'package:uuid/uuid.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({
    super.key,
    required this.onAddTodo,
    this.todo,
  });

  final void Function(Todo todo) onAddTodo;
  final Todo? todo;

  @override
  State<AddTodoScreen> createState() {
    return _AddTodoScreenState();
  }
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final TodoDatabase _todoDatabase = TodoDatabase();
  late String todoId;
  late String todoTitle;
  late String todoDesc;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      todoId = widget.todo!.id;
      todoTitle = widget.todo!.title;
      todoDesc = widget.todo!.description;
    } else {
      todoId = const Uuid().v4();
      todoTitle = '';
      todoDesc = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo != null ? 'Edit Todo' : 'Add Todo'),
      ),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a Todo',
                constraints: BoxConstraints(
                  maxWidth: 300,
                ),
              ),
              controller: TextEditingController(text: todoTitle),
              onChanged: (title) {
                todoTitle = title;
              },
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a Description',
                constraints: BoxConstraints(
                  maxWidth: 300,
                ),
              ),
              controller: TextEditingController(text: todoDesc),
              onChanged: (desc) {
                todoDesc = desc;
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(88, 36),
            ),
            onPressed: () async {
              if (todoTitle.isEmpty || todoDesc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a title and description'),
                  ),
                );
                return;
              }
              Todo todo = Todo(
                id: todoId,
                title: todoTitle,
                description: todoDesc,
              );
              if (widget.todo != null) {
                await _todoDatabase.updateTodo(todo);
              } else {
                await _todoDatabase.insertTodo(todo);
              }
              widget.onAddTodo(todo);
              Navigator.pop(context);
            },
            child: Text(widget.todo != null ? 'Update' : 'Add'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
