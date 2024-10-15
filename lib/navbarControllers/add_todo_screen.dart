import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/model/todo_db.dart';
import 'package:todo_offline/services/local_notification.dart';
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
  String _selectedNotificationPeriod = 'None';

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      todoId = widget.todo!.id;
      todoTitle = widget.todo!.title;
      todoDateController =
          TextEditingController(text: widget.todo!.dateCompleted);
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

  int _getTimeLeftInHours(String dateCompleted) {
    if (dateCompleted.isEmpty) {
      return 0;
    }
    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').parse(dateCompleted);
      final difference = date.difference(now);
      return difference.inHours;
    } catch (e) {
      return 0;
    }
  }

  int _getTimeLeftInDays(String dateCompleted) {
    if (dateCompleted.isEmpty) {
      return 0;
    }
    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').parse(dateCompleted);
      final difference = date.difference(now);
      return difference.inDays;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              hintText: 'Enter Completion Date',
                              labelText: 'Date Completed',
                              constraints: BoxConstraints(
                                maxWidth: 200,
                              ),
                            ),
                            controller: todoDateController,
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Reminder'),
                              DropdownButton<String>(
                                value: _selectedNotificationPeriod,
                                items: <String>['None', 'Hourly', 'Daily']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedNotificationPeriod = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ],
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
                      dateCompleted: todoDateController.text,
                      priority: todoPriority,
                      isCompleted: todoIsCompleted,
                    );
                    if (widget.todo != null) {
                      await _todoDatabase.updateTodo(todo);
                      LocalNotification.showSimpleNotification(
                        id: todo.id.hashCode,
                        title: 'Todo Updated',
                        body: 'Your todo has been updated',
                        chanId: todo.id,
                        payload: todo.id,
                      );
                    } else {
                      await _todoDatabase.insertTodo(todo);
                      LocalNotification.showSimpleNotification(
                        id: todo.id.hashCode,
                        title: 'Todo Added',
                        body: 'Your todo has been added',
                        chanId: todo.id,
                        payload: todo.id,
                      );
                    }

                    if (_selectedNotificationPeriod == 'Hourly') {
                      LocalNotification.cancelNotification(todo.id.hashCode);
                      LocalNotification.showHourlyNotification(
                        id: todo.id.hashCode,
                        title: 'Reminder',
                        body:
                        'Don\'t forget your todo: $todoTitle, due in ${_getTimeLeftInHours(todoDateController.text)} hours',
                        chanId: todo.id,
                        payload: todo.id,
                      );
                    } else if (_selectedNotificationPeriod == 'Daily') {
                      LocalNotification.cancelNotification(todo.id.hashCode);
                      LocalNotification.showDailyNotification(
                        id: todo.id.hashCode,
                        title: 'Reminder',
                        body:
                        'Don\'t forget your todo: $todoTitle, due in ${_getTimeLeftInDays(todoDateController.text)} days',
                        chanId: todo.id,
                        payload: todo.id,
                      );
                    }

                    widget.onAddTodo(todo);
                    Navigator.pop(context);
                  },
                  child: Text(widget.todo != null ? 'Update' : 'Add'),
                ),
                const SizedBox(height: 16),
              ],
            ),
        ),
      ),
    );
  }
}
