import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_offline/model/todo.dart';
import 'package:todo_offline/services/todo_db.dart';
import 'package:todo_offline/services/local_notification.dart';
import 'package:uuid/uuid.dart';
import 'date_picker_field.dart';

class TodoForm extends StatefulWidget {
  final void Function(Todo todo) onAddTodo;
  final Todo? todo;

  const TodoForm({
    super.key,
    required this.onAddTodo,
    this.todo,
  });

  @override
  State<TodoForm> createState() {
    return _TodoFormState();
  }
}

class _TodoFormState extends State<TodoForm> {
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
    try {
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
    } catch (e) {
      if(!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting date: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                  child: DatePickerField(
                    controller: todoDateController,
                    onTap: _selectDate,
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
                        items: <String>['None', 'Minutely', 'Hourly', 'Daily']
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
            try {
              if (widget.todo != null) {
                await _todoDatabase.updateTodo(todo);
                LocalNotification.showSimpleNotification(
                  id: todo.id.hashCode,
                  title: 'Todo ${todo.title} Updated',
                  body: 'Your todo has been set for ${todo.dateCompleted} with reminder set to $_selectedNotificationPeriod',
                  chanId: todo.id,
                  payload: todo.id,
                );
              } else {
                await _todoDatabase.insertTodo(todo);
                LocalNotification.showSimpleNotification(
                  id: todo.id.hashCode,
                  title: 'Todo ${todo.title} Added',
                  body: 'Your todo has been set for ${todo.dateCompleted} with reminder set to $_selectedNotificationPeriod',
                  chanId: todo.id,
                  payload: todo.id,
                );
              }

              if (await LocalNotification.isExactAlarmPermissionGranted() == false) {
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please grant permission to set exact alarms'),
                  ),
                );
                await LocalNotification.requestExactAlarmPermission();
                return;
              }

              if (_selectedNotificationPeriod == 'Hourly') {
                int notificationId = ('${todo.id}daily'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}minutely'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}hourly'.substring(0, 4)).hashCode;
                await LocalNotification.showHourlyNotification(
                  id: notificationId,
                  title: 'Reminder',
                  body: 'Don\'t forget your todo: $todoTitle, due in ${_getTimeLeftInHours(todoDateController.text)} hours',
                  chanId: todo.id,
                );
              } else if (_selectedNotificationPeriod == 'Daily') {
                int notificationId = ('${todo.id}hourly'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}minutely'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}daily'.substring(0, 4)).hashCode;
                await LocalNotification.showDailyNotification(
                  id: notificationId,
                  title: 'Reminder',
                  body: 'Don\'t forget your todo: $todoTitle, due in ${_getTimeLeftInDays(todoDateController.text)} days',
                  chanId: todo.id,
                );
              } else if (_selectedNotificationPeriod == 'Minutely') {
                int notificationId = ('${todo.id}hourly'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}daily'.substring(0, 4)).hashCode;
                if (await LocalNotification.isNotificationScheduled(notificationId)) {
                  await LocalNotification.cancelNotification(notificationId);
                }
                notificationId = ('${todo.id}minutely'.substring(0, 4)).hashCode;
                await LocalNotification.showMinutelyNotification(
                  id: notificationId,
                  title: 'Reminder',
                  body: 'Don\'t forget your todo: $todoTitle, due in ${_getTimeLeftInHours(todoDateController.text)} hours',
                  chanId: todo.id,
                );
              }

              widget.onAddTodo(todo);
              if (!context.mounted) {
                return;
              }
              Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error saving todo: $e')),
              );
            }
          },
          child: Text(widget.todo != null ? 'Update' : 'Add'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}