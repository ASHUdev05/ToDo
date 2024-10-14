import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  late TextEditingController todoDateController;
  late int todoPriority;
  late bool todoIsCompleted;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      todoId = widget.todo!.id;
      todoTitle = widget.todo!.title;
      todoDateController = TextEditingController(text: widget.todo!.dateCompleted);
      todoPriority = widget.todo!.priority;
      todoDesc = widget.todo!.description;

      todoIsCompleted = widget.todo!.isCompleted;
    } else {
      todoId = const Uuid().v4();
      todoTitle = '';
      todoDesc = '';
      todoDateController = TextEditingController();
      todoPriority = 0;
      todoIsCompleted = false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        todoDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
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
                labelText: 'Title',
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
                labelText: 'Description',
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
          Center(
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Completion Date',
                labelText: 'Date Completed',
                constraints: BoxConstraints(
                  maxWidth: 300,
                ),
              ),
              controller: todoDateController,
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const Text('Priority'),
                Slider(
                  value: todoPriority.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: todoPriority.toString(),
                  onChanged: (value) {
                    setState(() {
                      todoPriority = value.toInt();
                    });
                  },
                ),
              ],
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
              if (todoTitle.isEmpty || todoDesc.isEmpty || todoDateController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a title and description and date'),
                  ),
                );
                return;
              }
              Todo todo = Todo(
                id: todoId,
                title: todoTitle,
                description: todoDesc,
                dateCompleted: todoDateController.text,
                priority: todoPriority,
                isCompleted: todoIsCompleted,
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
