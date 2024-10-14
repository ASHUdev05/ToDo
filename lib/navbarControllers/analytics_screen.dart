import 'package:flutter/material.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/model/todo_db.dart';
import 'package:uuid/uuid.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({
    super.key,
    required this.onAddTodo,
  });

  final void Function(Todo todo) onAddTodo;

  @override
  State<AnalyticsScreen> createState() {
    return _AnalyticsScreenState();
  }
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TodoDatabase _todoDatabase = TodoDatabase();

  @override
  Widget build(BuildContext context) {
    var uuid = const Uuid();
    String todoId = '';
    String todoTitle = '';
    String todoDesc = '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a ToDo!'),
      ),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a Todo',
            ),
            onChanged: (title) {
              todoTitle = title;
              // if (kDebugMode) {
              //   print(todoTitle);
              // }
            },
          ),
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a Description',
            ),
            onChanged: (desc) {
              todoDesc = desc;
              // if (kDebugMode) {
              //   print(todoDesc);
              // }
            },
          ),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                if (todoTitle.isEmpty || todoDesc.isEmpty) {
                  // Display a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a title and description'),
                    ),
                  );
                  return;
                }
                todoId = uuid.v4();
                Todo todo = Todo(
                  id: todoId,
                  title: todoTitle,
                  description: todoDesc,
                );
                // if (kDebugMode) {
                //   print("title: ${todo.title}");
                // }
                await _todoDatabase.insertTodo(todo);
                widget.onAddTodo(todo);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ),
        ],
      ),
    );
  }
}
